ClientRequester = require('./lib/client-requester')

#
# PMP main api
#
#   Usage:
#
#   pmp = new PmpSdk
#     clientid:     'foo'
#     clientsecret: 'bar'
#     apiread:      'https://foobar.io'         (opt)
#     apiwrite:     'https://publish-foobar.io' (opt)
#     apimedia:     'https://media-foobar.io'   (opt)
#     debug:         false                      (opt)
#
class PmpSdk

  constructor: (config = {}) ->
    @requester = new ClientRequester
      basicauth:
        username: config.clientid
        password: config.clientsecret
      apiread:    config.apiread
      apiwrite:   config.apiwrite
      apimedia:   config.apimedia
      debug:      config.debug

  # TODO: stop this api-uri nonsense
  fetch: (link, callback) ->
    parts = link.replace('//', '').split('/')
    parts.shift()
    path = parts.join('/')
    @requester.get(path, callback)

module.exports = PmpSdk
