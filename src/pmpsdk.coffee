_        = require('underscore')
Creds    = require('./lib/creds')
Syncer   = require('./lib/syncer')
Document = require('./models/document')
Query    = require('./models/query')

#
# PMP api client
#
class PmpSdk

  constructor: (config = {}) ->
    @config = config
    @sync = new Syncer(config)

  # credentials (TODO: more better dry-er interface)
  credList: (callback) ->
    creds = new Creds(username: @config.username, password: @config.password, host: @config.host, debug: @config.debug)
    creds.list(callback)
  credCreate: (label, scope = 'read', expires = 1209600, callback) ->
    creds = new Creds(username: @config.username, password: @config.password, host: @config.host, debug: @config.debug)
    creds.create(label, scope, expires, callback)
  credDestroy: (id, callback) ->
    creds = new Creds(username: @config.username, password: @config.password, host: @config.host, debug: @config.debug)
    creds.destroy(id, callback)

  # fetch by guid/alias
  fetchHome: (callback) ->
    @sync.home callback
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

  # creation
  createDoc: (profileGuid, attrs, callback) ->
    @fetchProfile profileGuid, (profile, resp) =>
      if resp.success
        data =
          attributes: attrs,
          links:
            profile: [{href: profile.href}]
        doc = new Document(@sync, data)
        doc.save(callback, false)
      else
        callback(null, resp)
  createProfile: () ->
    # TODO
  createSchema: () ->
    # TODO
  createUpload: () ->
    # TODO

module.exports = PmpSdk
