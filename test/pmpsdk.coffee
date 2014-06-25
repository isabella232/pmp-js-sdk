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
  debug:        false
sdk = new PmpSdk(CFG)

describe 'pmpsdk test', ->

  describe '#creds', ->

    it 'lists credentials', (done) ->
      sdk.credList (resp) ->
        expect(resp.status).to.equal(200)
        expect(resp.success).to.be.true
        expect(resp.radix).to.be.an('array')
        done()

    it 'creates credentials', (done) ->
      sdk.credCreate TESTTAG, 'read', 10, (resp) ->
        expect(resp.status).to.equal(200)
        expect(resp.success).to.be.true
        expect(resp.radix).to.be.an('object')
        expect(resp.radix.label).to.equal(TESTTAG)
        done()

    it 'destroys credentials', (done) ->
      sdk.credCreate TESTTAG, 'read', 1000, (resp) ->
        expect(resp.success).to.be.true
        sdk.credDestroy resp.radix.client_id, (dresp) ->
          expect(dresp.status).to.equal(204)
          expect(dresp.success).to.be.true
          done()

  describe '#fetch', ->

    it 'fetches docs', (done) ->
      sdk.fetchDoc TESTGUID, (doc) ->
        expect(doc.href).to.include(TESTGUID)
        done()

    it 'fetches profiles', (done) ->
      sdk.fetchProfile 'story', (profile) ->
        expect(profile.href).to.include('story')
        done()

    it 'fetches schemas', (done) ->
      sdk.fetchSchema 'story', (schema) ->
        expect(schema.href).to.include('story')
        done()

  describe '#query', ->

    it 'queries for docs', (done) ->
      sdk.queryDocs {limit: 1}, (query) ->
        expect(query.items.length).to.equal(1)
        done()

    it 'queries for groups', (done) ->
      sdk.queryGroups {limit: 1}, (query) ->
        expect(query.items.length).to.equal(1)
        expect(query.items[0].items.length).to.be.above(0)
        expect(query.items[0].findProfileHref()).to.include('group')
        done()

    it 'queries for profiles', (done) ->
      sdk.queryProfiles {limit: 1}, (query) ->
        expect(query.items.length).to.equal(1)
        expect(query.items[0].findProfileHref()).to.include('profile')
        done()

    it 'queries for schemas', (done) ->
      sdk.querySchemas {limit: 1}, (query) ->
        expect(query.items.length).to.equal(1)
        expect(query.items[0].findProfileHref()).to.include('schema')
        done()

    it 'queries for users', (done) ->
      sdk.queryUsers {limit: 1}, (query) ->
        expect(query.items.length).to.equal(1)
        expect(query.items[0].findProfileHref()).to.match(/user|organization/)
        done()

  describe '#create', ->

    it 'creates documents', (done) ->
      attrs = {title: 'i am a test document', tags: [TESTTAG]}
      sdk.createDoc 'story', attrs, (doc, resp) ->
        expect(doc.attributes.title).to.equal('i am a test document')
        expect(doc.findProfileHref()).to.include('story')
        expect(resp.status).to.equal(202)
        done()

    it 'hates invalid guids', (done) ->
      attrs = {guid: '25c262f1-b29a-5d82-5dd0-3b29c9f5113$', title: 'i am a test document', tags: [TESTTAG]}
      sdk.createDoc 'story', attrs, (doc, resp) ->
        expect(resp.status).to.equal(400)
        expect(doc).to.be.null
        done()

# cleanup
after (done) ->
  sdk.queryDocs {tag: TESTTAG}, (query) ->
    if query.items.length == 0
      done()
    else
      total = query.items.length
      _.each query.items, (doc) ->
        doc.destroy (doc, resp) ->
          if resp.status == 401
            # TODO: search is still catching up
          else
            expect(resp.status).to.equal(204)
          total = total - 1
          done() if total == 0
