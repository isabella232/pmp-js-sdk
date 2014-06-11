request   = require('request')
responser = require('./responser')

#
# http requests against the pmp api
#
#   Usage:
#
#   req = new Requester
#     basicauth:
#       username: 'foo'
#       password: 'bar'
#     apiread:  'https://foobar.io'         (opt)
#     apiwrite: 'https://publish-foobar.io' (opt)
#     apimedia: 'https://media-foobar.io'   (opt)
#     debug:    false                       (opt)
#
class Requester

  configDefaults:
    apiread:  'https://api-pilot.pmp.io'
    apiwrite: 'https://publish-pilot.pmp.io'
    apimedia: 'https://media-pilot.pmp.io'

  constructor: (config = {}) ->
    @debug  = config.debug || false
    @config =
      headers:  {}
      apiread:  config.apiread  || @configDefaults.apiread
      apiwrite: config.apiwrite || @configDefaults.apiwrite
      apimedia: config.apimedia || @configDefaults.apimedia
    if config.basicauth
      @setBasicAuth(config.basicauth.username, config.basicauth.password)
    else
      console.error('authorization method required')

  setBasicAuth: (uname, pword) ->
    console.error('basicauth requires username') unless uname
    console.error('basicauth requires password') unless pword
    encoded = new Buffer("#{uname}:#{pword}").toString('base64')
    @config.headers['Authorization'] = "Basic #{encoded}"

  makeRequest: (params, callback) ->
    params.headers ||= {}
    for name, value of @config.headers
      params.headers[name] ||= value
    params.json = true
    params.callback = responser(callback)
    request(params)

  get: (path, callback) ->
    params = {method: 'GET', url: @config.apiread + path}
    @makeRequest(params, callback)

  post: (path, data, callback) ->
    serialized = []
    for k, v of data
      serialized.push "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}"
    serialized = serialized.join('&')
    params =
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      method: 'POST'
      url: @config.apiwrite + path
      body: serialized
    @makeRequest(params, callback)

  put: (path, data, callback) ->
    # TODO

  del: (path, callback) ->
    params = {method: 'DELETE', url: @config.apiwrite + path}
    @makeRequest(params, callback)

module.exports = Requester
