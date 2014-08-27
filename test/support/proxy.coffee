request = require('request')
http    = require('http')
url     = require('url')

# required configuration
config = require('./config.json')
if !config.host || !config.clientid || !config.clientsecret
  console.log('You need to create a valid config.json file!')
  process.exit(1)


# optional configuration
proxyHost = process.env['PROXY_HOST'] || 'http://localhost'
proxyPort = process.env['PROXY_PORT'] || 8008
isDebug   = process.env['DEBUG']      || false

# attempt to get a token
tokenOpts =
  url: "#{config.host}/auth/access_token"
  method: 'POST'
  auth: {user: config.clientid, pass: config.clientsecret}
  headers: {'Content-Type': 'application/x-www-form-urlencoded'}
request tokenOpts, (error, resp, body) ->
  if resp && resp.statusCode == 200
    if bearerToken = JSON.parse(body).access_token
      startProxyServer(bearerToken)
    else
      console.log('Unable to get a bearer token!')
      process.exit(1)
  else if resp && resp.statusCode == 401
    console.log('Invalid clientid / clientsecret in config.json')
    process.exit(1)
  else
    console.log('Invalid host in config.json')
    process.exit(1)

# start the proxy
startProxyServer = (token) ->
  readHost    = config.host
  writeHost   = config.host.replace('//api', '//publish')
  readRegexp  = new RegExp(readHost, 'g')
  writeRegexp = new RegExp(writeHost, 'g')

  # listener
  listener = (req, res) ->
    opts =
      url: url.resolve(readHost, req.url)
      method: req.method
      headers:
        'Accept': req.headers['accept'] || 'application/vnd.collection.doc+json'
        'Authorization': req.headers['authorization'] || 'Bearer ' + token
        'Content-Type': req.headers['content-type'] || 'application/vnd.collection.doc+json'
      body: ''
    if req.method == 'PUT' || req.method == 'POST'
      opts.url = url.resolve(writeHost, req.url)

    # set headers to allow any origin
    res.setHeader('Access-Control-Allow-Headers', 'origin, x-http-method-override, accept, content-type, authorization, x-pingother')
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,HEAD,PUT,POST,DELETE,PATCH')
    res.setHeader('Access-Control-Allow-Origin', req.headers.origin || '*')
    res.setHeader('Access-Control-Allow-Credentials', true)

    # get request body
    req.on 'data', (chunk) ->
      opts.body += chunk.toString()

    # wait for end of request cycle
    req.on 'end', ->
      console.log(req.method, req.url, '->', opts.url)
      console.time('req')       if isDebug
      console.log(opts.headers) if isDebug
      console.log(opts.body)    if isDebug

      request opts, (error, res2, body) ->
        console.timeEnd('req') if isDebug

        res.statusCode = res2.statusCode
        body = body.replace(readRegexp, proxyHost + ':' + proxyPort)
        body = body.replace(writeRegexp, proxyHost + ':' + proxyPort)

        # remove static links for non-home-doc
        if req.url != '/'
          try
            bodyObj = JSON.parse(body)
            delete bodyObj.links.query
            delete bodyObj.links.edit
            delete bodyObj.links.auth
            body = JSON.stringify(bodyObj)
          catch error
            # just ignore it

        res.write(body)
        res.end()

  # start the server
  http.createServer(listener).listen(proxyPort)
  console.log("\n", '... proxy listening on ' + proxyHost + ':' + proxyPort + ' ...', "\n")
