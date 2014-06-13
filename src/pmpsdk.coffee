_        = require('underscore')
Syncer   = require('./lib/syncer')
Document = require('./models/document')
Query    = require('./models/query')

#
# PMP api client
#
class PmpSdk

  constructor: (config = {}) ->
    @sync = new Syncer(config)

  fetchDoc: (guid, callback) ->
    @sync.home (home) =>
      Document.load @sync, home.docFetch(guid), callback

  queryDocs: (params, callback) ->
    @sync.home (home) =>
      Query.load @sync, home.docQuery(params), callback

module.exports = PmpSdk
