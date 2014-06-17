test    = require('./support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
PmpSdk  = test.nocache('../../src/pmpsdk')

TESTGUID = '3501576e-1fb7-4b67-8628-3347d42666c3'
TESTTAG  = 'pmp_js_sdk_testcontent'
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
  host:         CONFIG.host
  debug:        false
sdk = new PmpSdk(CFG)

describe 'pmpsdk test', ->

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
        expect(query.items[0].findProfileHref()).to.include('organization')
        done()

  describe '#create', ->

    it 'creates documents', (done) ->
      attrs = {title: 'i am a test document', tags: [TESTTAG]}
      sdk.createDoc 'story', attrs, (doc, resp) ->
        expect(doc.attributes.title).to.equal('i am a test document')
        expect(doc.findProfileHref()).to.include('story')
        expect(resp.status).to.equal(202)
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
          expect(resp.status).to.equal(204)
          total = total - 1
          done() if total == 0
