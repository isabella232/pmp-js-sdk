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
    auth:     null
    accept:   'application/json'
    apiread:  'https://api-pilot.pmp.io'
    apiwrite: 'https://publish-pilot.pmp.io'
    apimedia: 'https://media-pilot.pmp.io'

  constructor: (config = {}) ->
    @debug  = config.debug || false
    @config =
      auth:     config.auth     || @configDefaults.auth
      accept:   config.accept   || @configDefaults.accept
      apiread:  config.apiread  || @configDefaults.apiread
      apiwrite: config.apiwrite || @configDefaults.apiwrite
      apimedia: config.apimedia || @configDefaults.apimedia
    if config.basicauth
      @setBasicAuth(config.basicauth.username, config.basicauth.password)
    else if config.bearerauth
      @setBearerAuth(config.bearerauth)
    else
      console.error('authorization method required')

  setBasicAuth: (uname, pword) ->
    console.error('basicauth requires username') unless uname
    console.error('basicauth requires password') unless pword
    encoded = new Buffer("#{uname}:#{pword}").toString('base64')
    @config.auth = "Basic #{encoded}"

  setBearerAuth: (token) ->
    console.error('bearerauth requires token') unless token
    @config.auth = "Bearer #{token}"

  makeRequest: (params, callback) ->
    params.headers ||= {}
    params.headers['Authorization'] = @config.auth
    params.headers['Accept'] = @config.accept
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
