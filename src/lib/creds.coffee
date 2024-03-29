_         = require('underscore')
request   = require('request')
responser = require('./responser')
BaseDoc   = require('../models/base')

#
# pmp client credentials
#
# TODO: share backend with syncer
#
class Creds

  configDefaults =
    accept:      'application/json'
    contentType: 'application/x-www-form-urlencoded'
    host:        'https://api-foobar.pmp.io'
    username:    null
    password:    null
    debug:       false

  constructor: (config = {}) ->
    @_home   = null
    @_config = _.defaults(config, configDefaults)

  home: (callback) ->
    if @_home
      callback(@_home)
    else
      @_request 'get', @_config.host, null, (resp) =>
        if resp.success
          @_home = new BaseDoc(resp.radix)
          unless @_home.credList() && @_home.credCreate() && @_home.credDestroy()
            resp.success = false
            resp.status  = 500
            resp.message = 'Home document missing auth token links'
          callback(@_home)
        else
          callback(null, resp)

  list: (callback) ->
    @home (home, errorResp = null) =>
      if home
        @_request 'get', home.credList(), null, (resp) ->
          if resp.success
            resp.radix = if resp.radix then resp.radix.clients else []
          else
            resp.radix = resp.radix
          callback(resp)
      else
        callback(errorResp)

  create: (label, scope = 'read', expires = 1209600, callback) ->
    @home (home, errorResp = null) =>
      if home
        data = {label: label, scope: scope, token_expires_in: expires}
        @_request 'post', home.credCreate(), data, callback
      else
        callback(errorResp)

  destroy: (id, callback) ->
    @home (home, errorResp = null) =>
      if home
        @_request 'delete', home.credDestroy(id), null, callback
      else
        callback(errorResp)

  ########  ########  #### ##     ##    ###    ######## ########
  ##     ## ##     ##  ##  ##     ##   ## ##      ##    ##
  ##     ## ##     ##  ##  ##     ##  ##   ##     ##    ##
  ########  ########   ##  ##     ## ##     ##    ##    ######
  ##        ##   ##    ##   ##   ##  #########    ##    ##
  ##        ##    ##   ##    ## ##   ##     ##    ##    ##
  ##        ##     ## ####    ###    ##     ##    ##    ########

  # http request
  _request: (method, url, data = {}, callback = null) ->
    if method == 'home'
      callback(@_home)
    else
      params = @_getRequestParams(method, url, data)
      wrappedCallback = responser.http(callback)
      wrappedCallback = responser.safeDecode(wrappedCallback)
      wrappedCallback = @_debugCallback(params, wrappedCallback, @_config.debug) if @_config.debug
      request(params, wrappedCallback)

  # assemble params
  _getRequestParams: (method, url, data) ->
    params =
      method:  method.toUpperCase()
      url:     url
      auth:    {user: @_config.username, pass: @_config.password}
      headers: {'Accept': @_config.accept}
    unless _.isEmpty(data)
      serialized = _.map data, (v, k) -> "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}"
      params.body = serialized.join('&')
      params.headers['Content-Type'] = @_config.contentType
    params

  # debugging
  _debugCallback: (params, originalCallback, level) ->
    (err, resp, body) =>
      if err
        console.log "### ??? - #{params.method} #{params.url}"
        console.log "###       #{err}"
      else
        console.log "### #{resp.statusCode} - #{params.method} #{params.url}"
        if level == 2 || level == '2'
          console.log "###       #{body}"
      originalCallback(err, resp, body)

# class export
module.exports = Creds
