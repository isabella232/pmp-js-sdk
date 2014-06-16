_         = require('underscore')
request   = require('request')
responser = require('./responser')
BaseDoc   = require('../models/base')

#
# http requests against the pmp api
#
class Syncer

  configDefaults =
    accept:       'application/json'
    contenttype:  'application/vnd.collection.doc+json'
    host:         'https://api-pilot.pmp.io'
    clientid:     null
    clientsecret: null
    debug:        false

  constructor: (config = {}) ->
    @_home   = null
    @_queue  = []
    @_token  = null
    @_fetchingToken = false
    @_config = _.defaults(config, configDefaults)
    @_authenticate()

  home: (callback) ->
    @_requestOrQueue('home', null, null, callback)

  get: (url, callback) ->
    @_requestOrQueue('get', url, null, callback)

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
      callback(@_home)
    else
      params = @_getRequestParams(method, url, params)
      params.callback = responser.http(callback)
      params.callback = @_debugCallback(params, params.callback) if @_config.debug
      request(params)

  # assemble params
  _getRequestParams: (method, url, params) ->
    params.method = method.toUpperCase()
    params.url = url
    if @_token
      params.auth = {bearer: @_token}
    else
      params.auth = {user: @_config.clientid, pass: @_config.clientsecret}
    params.json = true
    params.headers = _.defaults(params.headers || {}, {Accept: @_config.accept})
    params

  # retry 401's once - for token expirations
  _retryCallback: (args, originalCallback) ->
    (resp) =>
      if resp.status == 401
        @_queue.push(args)
        @_authenticate()
      else
        originalCallback(resp)

  # debugging
  _debugCallback: (params, originalCallback) ->
    (err, resp, body) =>
      if err
        console.log "### ??? - #{params.method} #{params.url}"
        # console.log "###       #{err}"
      else
        console.log "### #{resp.statusCode} - #{params.method} #{params.url}"
        # console.log "###       #{JSON.stringify(body)}"
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
        if _.first(args) == 'home' then _.last(args)(null) else _.last(args)(errorResp)
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
    @_request 'get', @_config.host, null, (resp) =>
      if resp.success
        @_home = new BaseDoc(resp.radix)
        unless @_home.authCreate()
          resp.success = false
          resp.status  = 500
          resp.message = 'Home document missing auth token issue link'
      callback(resp)

# class export
module.exports = Syncer
