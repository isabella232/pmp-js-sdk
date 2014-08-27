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
  debug:        false
sync = new Syncer(CFG)

TESTHREF = null
TESTTAG  = 'pmp_js_sdk_testcontent'
TESTDOC  =
  version: '1.0'
  attributes:
    title: 'i am a test document'
    tags: [TESTTAG]
  links:
    profile: [{href: "#{CONFIG.host}/profiles/story"}]

describe 'document test', ->

  describe '#load', ->

    it 'fetches the home document', (done) ->
      Document.load sync, CONFIG.host, (doc, resp) ->
        expect(doc).to.be
        expect(doc.href).to.match(///#{CONFIG.host}///)
        done()

  describe '#save', ->

    it 'creates a new document, without waiting', (done) ->
      doc = new Document(sync, TESTDOC)
      doc.save (doc, resp) ->
        expect(resp.status).to.equal(202)
        expect(doc.href).to.be
        expect(doc.attributes.guid).to.be
        done()

    it 'creates a new document, waiting for resolution', (done) ->
      @timeout(30000)

      doc = new Document(sync, TESTDOC)
      doc.save true, (doc, resp) ->
        expect(resp.status).to.equal(200)
        expect(doc.href).to.be
        expect(doc.attributes.guid).to.be
        expect(doc.attributes.created).to.be
        expect(doc.attributes.title).to.equal(TESTDOC.attributes.title)
        expect(doc.attributes.tags).to.include(TESTTAG)
        expect(doc.links.creator).to.be.an('array')
        expect(doc.links.profile).to.include(TESTDOC.links.profile[0])
        TESTHREF = doc.href
        done()

    it 'updates an existing document, without waiting', (done) ->
      Document.load sync, TESTHREF, (doc, resp) ->
        expect(resp.status).to.equal(200)
        doc.title = 'foobar1'
        doc.save (doc, resp) ->
          expect(resp.status).to.equal(202)
          expect(resp.radix.attributes?).to.be.false
          done()

    it 'updates an existing document, waiting for change', (done) ->
      @timeout(30000)
      Document.load sync, TESTHREF, (doc, resp) ->
        expect(resp.status).to.equal(200)
        doc.title = 'foobar1'
        doc.save true, (doc, resp) ->
          expect(resp.status).to.equal(200)
          expect(resp.radix.attributes.title).to.equal('foobar1')
          expect(doc.attributes.title).to.equal('foobar1')
          done()

  describe '#destroy', ->

    it 'deletes existing documents', (done) ->
      Document.load sync, TESTHREF, (doc, resp) ->
        expect(resp.status).to.equal(200)
        doc.destroy (doc, resp) ->
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

        # TODO: what's with the null results?
        if doc.href
          doc.destroy (doc, resp) ->
            expect(resp.status).to.equal(204)
            total = total - 1
            done() if total == 0
        else
          total = total - 1
          done() if total == 0
