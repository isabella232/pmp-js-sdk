test     = require('../support/test')
_        = test.underscore
expect   = test.expect
CONFIG   = test.config
PmpSdk   = test.nocache('../../src/pmpsdk')
Syncer   = test.nocache('../../src/lib/syncer')
Document = test.nocache('../../src/models/document')

CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        test.debug

SAVEDDOC = false
TESTTAG  = 'pmp_js_sdk_testcontent'
TESTDOC  =
  version: '1.0'
  attributes:
    title: 'i am a test document'
    tags: [TESTTAG]
  links:
    profile: [{href: "#{CONFIG.host}/profiles/story"}]

describe 'document test', ->

  before ->
    @sync = new Syncer(CFG)

  describe '#load', ->

    it 'fetches the home document', (done) ->
      Document.load @sync, CONFIG.host, (doc, resp) ->
        expect(doc).to.be
        expect(doc.href).to.match(///#{CONFIG.host}///)
        done()

  describe '#save', ->

    it 'creates a new document, without waiting', (done) ->
      doc = new Document(@sync, TESTDOC)
      doc.save (doc, resp) ->
        expect(resp.status).to.equal(202)
        expect(doc.href).to.be
        expect(doc.attributes.guid).to.be
        done()

    it 'creates a new document, waiting for resolution', (done) ->
      @timeout(30000)

      doc = new Document(@sync, TESTDOC)
      doc.save true, (doc, resp) ->
        expect(resp.status).to.equal(200)
        expect(doc.href).to.be
        expect(doc.attributes.guid).to.be
        expect(doc.attributes.created).to.be
        expect(doc.attributes.title).to.equal(TESTDOC.attributes.title)
        expect(doc.attributes.tags).to.include(TESTTAG)
        expect(doc.links.creator).to.be.an('array')
        expect(doc.links.profile).to.include(TESTDOC.links.profile[0])
        SAVEDDOC = doc
        done()

    it 'updates an existing document, waiting for change', (done) ->
      @timeout(30000)

      unless SAVEDDOC
        expect().fail('no saved doc - bailing!')

      SAVEDDOC.attributes.title = 'foobar2'
      SAVEDDOC.save true, (doc, resp) ->
        expect(resp.status).to.equal(200)
        expect(resp.radix.attributes.title).to.equal('foobar2')
        expect(doc.attributes.title).to.equal('foobar2')
        done()

    it 'updates an existing document, without waiting', (done) ->
      unless SAVEDDOC
        expect().fail('no saved doc - bailing!')

      SAVEDDOC.attributes.title = 'foobar1'
      SAVEDDOC.save (doc, resp) ->
        expect(resp.status).to.equal(202)
        expect(resp.radix.attributes?).to.be.false
        done()

  describe '#destroy', ->

    it 'deletes existing documents', (done) ->
      unless SAVEDDOC
        expect().fail('no saved doc - bailing!')

      SAVEDDOC.destroy (doc, resp) ->
        expect(resp.status).to.equal(204)
        expect(doc.href).to.be.null
        done()

  # cleanup
  after (done) ->
    sdk = new PmpSdk(CFG)
    sdk.queryDocs {tag: TESTTAG}, (query) ->
      if query.items.length == 0
        done()
      else
        total = query.items.length
        _.each query.items, (doc) ->
          doc.destroy (doc, resp) ->
            total = total - 1
            done() if total == 0
