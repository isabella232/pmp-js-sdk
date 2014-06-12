request   = require('request')
responser = require('./responser')
Requester = require('./requester')

#
# A requester for an authorized client with valid credentials.  This will
# GUARANTEE that you have a valid access token, and will attempt to renew
# any expired token.
#
#   Usage:
#
#   req = new ClientRequester
#     basicauth:
#       username: 'client-id'
#       password: 'client-secret'
#     apiread:  'https://foobar.io'         (opt)
#     apiwrite: 'https://publish-foobar.io' (opt)
#     apimedia: 'https://media-foobar.io'   (opt)
#     debug:    false                       (opt)
#
class ClientRequester extends Requester

  constructor: (config = {}) ->
    super(config)
    @requestQueue = []
    @config.basicauth = @config.auth
    @config.auth = null
    @getBearerAuth()

  # async request for a new token
  # TODO: form data not working - have to use query variables - BUG!
  # TODO: this is sort of hacky anyways
  getBearerAuth: ->
    request
      headers:
        'Authorization': @config.basicauth
        'Content-Type': 'application/x-www-form-urlencoded'
      method: 'POST'
      url: @config.apiwrite + '/auth/access_token?grant_type=client_credentials'
      json: true
      callback: responser (resp) =>
        if resp.success
          @config.auth = "Bearer #{resp.radix.access_token}"
          @clearQueue()
        else
          @clearQueue(resp)

  # clear out queue, optionally returning token error
  clearQueue: (errorResp = null) ->
    while @requestQueue.length > 0
      request = @requestQueue.shift()
      if errorResp
        request[1](errorResp)
      else
        @makeRequest(request[0], request[1])

  # queue all requests until bearer auth is set
  makeRequest: (params, callback) ->
    if @config.auth
      super(params, callback)
    else
      @requestQueue.push([params, callback])

module.exports = ClientRequester
