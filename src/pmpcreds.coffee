Requester = require('./lib/requester')

#
# PMP credentials api
#
#   Usage:
#
#   creds = new PmpCreds
#     username: 'foo'
#     password: 'bar'
#     apiread:  'https://foobar.io'         (opt)
#     apiwrite: 'https://publish-foobar.io' (opt)
#     debug:    false                       (opt)
#
class PmpCreds

  constructor: (config = {}) ->
    console.error('username is required') unless config.username
    console.error('password is required') unless config.password
    @requester = new Requester
      basicauth:
        username: config.username
        password: config.password
      apiread:    config.apiread
      apiwrite:   config.apiwrite
      debug:      config.debug

  list: (callback) ->
    @requester.get '/auth/credentials', (resp) ->
      resp.radix = resp.radix.clients if resp.radix
      callback(resp)

  create: (label, scope = 'read', expires = 1209600, callback) ->
    data = {label: label, scope: scope, token_expires_in: expires}
    @requester.post '/auth/credentials', data, callback

  destroy: (id, callback) ->
    @requester.del "/auth/credentials/#{id}", callback

module.exports = PmpCreds
