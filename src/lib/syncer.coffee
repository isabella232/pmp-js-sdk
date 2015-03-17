_         = require('underscore')
request   = require('request')
responser = require('./responser')
BaseDoc   = require('../models/base')
PkgJson   = require('../../package.json')

#
# http requests against the pmp api
#
class Syncer

  configDefaults =
    accept:       'application/vnd.collection.doc+json'
    contenttype:  'application/vnd.collection.doc+json'
    host:         'https://api-foobar.pmp.io'
    useragent:    'pmp-js-sdk-' + PkgJson.version
    clientid:     null
    clientsecret: null
    debug:        false
    minimal:      true
    gzipped:      true

  constructor: (config = {}) ->
    @_home     = null
    @_homeResp = null
    @_queue    = []
    @_token    = null
    @_fetchingToken = false
    @_config = _.defaults(config, configDefaults)
    @_authenticate()

  token: (callback) ->
    @home => callback(@_token)

  home: (callback) ->
    @_requestOrQueue('home', null, null, callback)

  get: (url, callback) ->
    @_requestOrQueue('get', url, null, callback)

  poll: (url, callback) ->
    @_requestOrQueue('poll', url, null, callback)

  post: (url, data, callback) ->
    @_requestOrQueue('post', url, {body: JSON.stringify(data), headers: 'Content-Type': @_config.contenttype}, callback)

  put: (url, data, callback) ->
    @_requestOrQueue('put', url, {body: JSON.stringify(data), headers: 'Content-Type': @_config.contenttype}, callback)

  del: (url, callback) ->
    @_requestOrQueue('delete', url, null, callback)

  ########  ########  #### ##     ##    ###    ######## ########
  ##     ## ##     ##  ##  ##     ##   ## ##      ##    ##
  ##     ## ##     ##  ##  ##     ##  ##   ##     ##    ##
  ########  ########   ##  ##     ## ##     ##    ##    ######
  ##        ##   ##    ##   ##   ##  #########    ##    ##
  ##        ##    ##   ##    ## ##   ##     ##    ##    ##
  ##        ##     ## ####    ###    ##     ##    ##    ########

  # http request
  _request: (method, url, params = {}, callback = null) ->
    if method == 'home'
      callback(@_home, @_homeResp)
    else
      params = @_getRequestParams(method, url, params)
      wrappedCallback = responser.http(callback)
      wrappedCallback = @_debugCallback(params, wrappedCallback, @_config.debug) if @_config.debug
      request(params, wrappedCallback)

  # assemble params
  _getRequestParams: (method, url, params) ->
    params.method = method.toUpperCase()
    params.originalMethod = params.method
    params.method = 'GET' if params.method == 'POLL'
    params.url = url
    if params.auth == false
      delete params.auth
    else if @_token
      params.auth = {bearer: @_token}
    else if @_config.clientid && @_config.clientsecret
      params.auth = {user: @_config.clientid, pass: @_config.clientsecret}
    params.json = true
    params.headers = _.defaults(params.headers || {}, {
      'Accept': @_config.accept,
      'User-Agent': @_config.useragent
    })

    # optional gzipped and minimal responses
    if @_config.minimal && @_token
      params.headers['Prefer'] = 'return=minimal'
    if @_config.gzipped
      params.gzip = true

    params

  # retry 401's once - for token expirations
  _retryCallback: (args, originalCallback) ->
    (resp) =>
      if resp.status == 401
        @_queue.push(args)
        @_authenticate()
      else
        originalCallback.apply(@, arguments)

  # debugging
  _debugCallback: (params, originalCallback, level) ->
    (err, resp, body) =>
      if err
        console.log "### ??? - #{params.originalMethod} #{params.url}"
        console.log "###       #{err}"
      else
        console.log "### #{resp.statusCode} - #{params.originalMethod} #{params.url}"
        if level == 2 || level == '2'
          console.log "###       #{JSON.stringify(body)}"
      originalCallback(err, resp, body)

  # queue requests until we get an auth token
  _requestOrQueue: (method, url, params = {}, callback = null) ->
    if @_token
      @_request(method, url, params, @_retryCallback(arguments, callback))
    else
      @_queue.push(arguments)
      @_authenticate()

  # clear out queue, either firing requests or returning an error response
  _clearQueue: (errorResp = null) ->
    while @_queue.length > 0
      args = @_queue.shift()
      if errorResp
        if _.first(args) == 'home'
          _.last(args)(@_home, @_homeResp)
        else
          _.last(args)(errorResp)
      else
        @_request.apply(@, args)

  # chain fetching home doc and auth token
  _authenticate: ->
    unless @_fetchingToken
      @_token = null
      @_fetchingToken = true
      @_fetchHome (resp) =>
        if resp.success
          @_fetchToken (resp) =>
            @_fetchingToken = false
            if resp.success
              @_token = resp.radix.access_token
              @_clearQueue()
            else
              @_clearQueue(resp)
        else
          @_fetchingToken = false
          @_clearQueue(resp)

  # get an auth token - @_home doc MUST be set
  _fetchToken: (callback) ->
    opts =
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      body: 'grant_type=client_credentials'
    @_request 'post', @_home.authCreate(), opts, callback

  # get home document
  _fetchHome: (callback) ->
    @_request 'get', @_config.host, {auth: false}, (resp) =>
      @_homeResp = resp
      if resp.success
        @_home = new BaseDoc(resp.radix)
        unless @_home.authCreate()
          resp.success = false
          resp.status  = 500
          resp.message = 'Home document missing auth token issue link'
      callback(resp)

# class export
module.exports = Syncer
