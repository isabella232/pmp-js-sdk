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
    @config.clientid = @config.client_id if @config.client_id
    @config.clientsecret = @config.client_secret if @config.client_secret
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
  token: (callback) ->
    @sync.token(callback)

  # fetch by guid/alias
  fetchHome: (callback) ->
    @sync.home callback
  fetchDoc: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.docFetch(guid), callback
  fetchProfile: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.profileFetch(guid), callback
  fetchSchema: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.schemaFetch(guid), callback
  fetchTopic: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.topicFetch(guid), callback
  fetchUser: (guid, callback) ->
    @sync.home (home) => Document.load @sync, home.userFetch(guid), callback

  # querying
  queryCollection: (guid, params, callback) ->
    @sync.home (home) => Query.load @sync, home.collectionQuery(guid, params), callback
  queryDocs: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.docQuery(params), callback
  queryGroups: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.groupQuery(params), callback
  queryProfiles: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.profileQuery(params), callback
  querySchemas: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.schemaQuery(params), callback
  queryTopics: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.topicQuery(params), callback
  queryUsers: (params, callback) ->
    @sync.home (home) => Query.load @sync, home.userQuery(params), callback

  # direct access by absolute url
  fetchUrl: (url, callback) ->
    Document.load @sync, url, callback
  queryUrl: (url, callback) ->
    Query.load @sync, url, callback

  # new unsaved doc, that will assign it's own profile link on first save
  newDoc: (profileGuid, attrs) ->
    doc = new Document(@sync, {attributes: attrs})
    doc.save = _.wrap doc.save, (oldSave, oldArgs...) =>
      @sync.home (home) =>
        if profileGuid || !doc.links.profile
          doc.links.profile = [{href: home.profileFetch(profileGuid)}]
        doc.save = oldSave
        oldSave.apply(doc, oldArgs)
    doc

  # create and save a doc
  createDoc: (profileGuid, attrs, wait, callback) ->
    doc = @newDoc(profileGuid, attrs)
    doc.save(wait, callback)

  # serialize/unserialize for caching
  serialize: (callback) ->
    @sync.home (home, homeResp) =>
      @sync.token (token) =>
        if homeResp && token
          savedConfig = _.pick(@config, 'host', 'clientid', 'clientsecret', 'username', 'password')
          savedConfig.token = token
          savedConfig.home = homeResp.radix
          callback(JSON.stringify(savedConfig))
        else
          callback(null)
  serializeTokenOnly: (callback) =>
    @serialize (str) =>
      if str
        savedConfig = _.omit(JSON.parse(str), 'clientid', 'clientsecret', 'username', 'password')
        callback(JSON.stringify(savedConfig))
      else
        callback(str)

# static method to unserialize sdk
PmpSdk.unserialize = (str, overrides) ->
  new PmpSdk(_.defaults(overrides, JSON.parse(str)))

module.exports = PmpSdk
