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

  # fetch by guid/alias
  fetchDoc: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.docFetch(guid), callback
  fetchProfile: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.profileFetch(guid), callback
  fetchSchema: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.schemaFetch(guid), callback

  # querying
  queryDocs: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.docQuery(params), callback
  queryGroups: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.groupQuery(params), callback
  queryProfiles: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.profileQuery(params), callback
  querySchemas: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.schemaQuery(params), callback
  queryUsers: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.userQuery(params), callback

module.exports = PmpSdk
