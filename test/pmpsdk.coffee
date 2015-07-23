test    = require('./support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
PmpSdk  = test.nocache('../../src/pmpsdk')

TESTGUID = 'fabc86a2-4c7a-11e3-8e77-ce3f5508acd9'
TESTTAG  = 'pmp_js_sdk_testcontent'
TESTCRED = null
TESTDOC  =
  version: '1.0'
  attributes:
    title: 'i am a test document'
    tags: [TESTTAG]
  links:
    profile: [{href: "#{CONFIG.host}/profiles/story"}]

CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  username:     CONFIG.username
  password:     CONFIG.password
  host:         CONFIG.host
  debug:        test.debug

describe 'pmpsdk test', ->

  before ->
    @sdk = new PmpSdk(CFG)

  describe '#creds', ->

    it 'lists credentials', (done) ->
      @sdk.credList (resp) ->
        expect(resp).to.be.a.response(200)
        expect(resp.radix).to.be.an('array')
        done()

    it 'creates credentials', (done) ->
      @sdk.credCreate TESTTAG, 'read', 10, (resp) ->
        expect(resp).to.be.a.response(200)
        expect(resp.radix).to.be.an('object')
        expect(resp.radix.label).to.equal(TESTTAG)
        done()

    it 'destroys credentials', (done) ->
      @sdk.credCreate TESTTAG, 'read', 1000, (resp) =>
        expect(resp).to.be.a.response(200)
        @sdk.credDestroy resp.radix.client_id, (dresp) ->
          expect(dresp).to.be.a.response(204)
          expect(dresp.success).to.be.true
          done()

  describe '#fetch', ->

    it 'fetches docs', (done) ->
      @sdk.fetchDoc TESTGUID, (doc, resp) ->
        expect(resp).to.be.a.response(200)
        expect(doc.href).to.include(TESTGUID)
        done()

    it 'fetches profiles', (done) ->
      @sdk.fetchProfile 'story', (profile, resp) ->
        expect(resp).to.be.a.response(200)
        expect(profile.href).to.include('story')
        done()

    it 'fetches schemas', (done) ->
      @sdk.fetchSchema 'story', (schema, resp) ->
        expect(resp).to.be.a.response(200)
        expect(schema.href).to.include('story')
        done()

    it 'fetches users', (done) ->
      @sdk.fetchUser 'me', (user, resp) =>
        expect(resp).to.be.a.response(200)
        expect(user.href).to.include('me')
        expect(user.attributes.auth.user).to.equal(CONFIG.username)
        @sdk.fetchUser user.attributes.guid, (user2, resp2) ->
          expect(resp2).to.be.a.response(200)
          expect(user2.attributes.title).to.equal(user.attributes.title)
          done()

    it 'also accepts the underscore-d versions of clientid/secret', (done) ->
      CFG2 = _.omit(CFG, 'clientid', 'clientsecret')
      CFG2.client_id = CFG.clientid
      CFG2.client_secret = CFG.clientsecret
      sdk2 = new PmpSdk(CFG2)
      sdk2.fetchDoc TESTGUID, (doc, resp) ->
        expect(resp).to.be.a.response(200)
        expect(doc.href).to.include(TESTGUID)
        done()

  describe '#query', ->

    it 'queries for docs', (done) ->
      @sdk.queryDocs {limit: 1}, (query, resp) ->
        expect(resp).to.be.a.response(200)
        expect(query.items.length).to.equal(1)
        done()

    it 'queries for groups', (done) ->
      @sdk.queryGroups {limit: 1, text: 'NOT test'}, (query, resp) ->
        expect(resp).to.be.a.response(200)
        expect(query.items.length).to.equal(1)
        expect(query.items[0].items.length).to.be.above(0)
        expect(query.items[0].findProfileHref()).to.include('group')
        done()

    it 'queries for profiles', (done) ->
      @sdk.queryProfiles {limit: 1}, (query, resp) ->
        expect(resp).to.be.a.response(200)
        expect(query.items.length).to.equal(1)
        expect(query.items[0].findProfileHref()).to.include('profile')
        done()

    it 'queries for schemas', (done) ->
      @sdk.querySchemas {limit: 1}, (query, resp) ->
        expect(resp).to.be.a.response(200)
        expect(query.items.length).to.equal(1)
        expect(query.items[0].findProfileHref()).to.include('schema')
        done()

    it 'queries for users', (done) ->
      @sdk.queryUsers {limit: 1}, (query, resp) ->
        expect(resp).to.be.a.response(200)
        expect(query.items.length).to.equal(1)
        expect(query.items[0].findProfileHref()).to.match(/user|organization/)
        done()

  describe '#create', ->

    it 'creates documents', (done) ->
      attrs = {title: 'i am a test document', tags: [TESTTAG]}
      @sdk.createDoc 'story', attrs, (doc, resp) ->
        expect(resp).to.be.a.response(202)
        expect(doc.attributes.title).to.equal('i am a test document')
        expect(doc.findProfileHref()).to.include('story')
        done()

    it 'hates invalid guids', (done) ->
      attrs = {guid: '25c262f1-b29a-5d82-5dd0-3b29c9f5113$', title: 'i am a test document', tags: [TESTTAG]}
      @sdk.createDoc 'story', attrs, (doc, resp) ->
        expect(resp).to.be.a.response(400)
        expect(doc).to.be.null
        expect(resp.message).to.equal('Bad Request')
        expect(JSON.stringify(resp.radix)).to.match(/validation failed against schema/i)
        done()

  # cleanup
  after (done) ->
    @sdk.credList (resp) =>
      testids = _.pluck _.where(resp.radix, label: TESTTAG), 'client_id'
      done() if testids.length == 0
      _.each testids, (id) =>
        @sdk.credDestroy id, (dresp) ->
          testids = _.filter testids, (tid) -> tid != id
          done() if testids.length == 0
  after (done) ->
    @sdk.queryDocs {tag: TESTTAG}, (query) ->
      total = query.items.length
      done() if total == 0
      _.each query.items, (doc) ->
        doc.destroy (doc, resp) ->
          total = total - 1
          done() if total == 0
