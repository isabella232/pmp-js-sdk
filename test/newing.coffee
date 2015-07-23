test    = require('./support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
PmpSdk  = test.nocache('../../src/pmpsdk')

TESTGUID = null
TESTTAG  = 'pmp_js_sdk_testcontent'
CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        test.debug

describe 'sdk new documents', ->

  before ->
    @sdk = new PmpSdk(CFG)

  describe 'newDoc', ->

    it 'creates new documents without saving', (done) ->
      doc = @sdk.newDoc()
      expect(doc.attributes).to.not.have.property('created')
      expect(doc.attributes).to.not.have.property('guid')
      expect(doc.links).to.not.have.property('profile')
      done()

    it 'accepts attributes in the constructor', (done) ->
      doc = @sdk.newDoc('foobar', {guid: 'foobar', hello: 'world'})
      expect(doc.attributes).to.not.have.property('created')
      expect(doc.links).to.not.have.property('profile')
      expect(doc.attributes.guid).to.equal('foobar')
      expect(doc.attributes.hello).to.equal('world')
      done()

    it 'cannot set a profile if you do not provide one', (done) ->
      doc = @sdk.newDoc()
      doc.attributes.title = 'i am a test document'
      doc.attributes.tags = [TESTTAG]
      doc.save (doc, resp) ->
        expect(resp).to.be.a.response(400)
        done()

    it 'can save with a valid profile', (done) ->
      doc = @sdk.newDoc('base')
      doc.attributes.title = 'i am a test document'
      doc.attributes.tags = [TESTTAG]
      doc.save true, (doc, resp) ->
        expect(resp).to.be.a.response(200)
        TESTGUID = doc.attributes.guid
        expect(doc.attributes.guid).to.be
        expect(doc.attributes.title).to.equal('i am a test document')
        expect(doc.links).to.have.property('profile')
        expect(doc.links.profile[0].href).to.include('profiles/base')
        doc.attributes.title = 'changing the test title'
        doc.save true, (doc, resp) ->
          expect(resp).to.be.a.response(200)
          expect(doc.attributes.guid).to.equal(TESTGUID)
          expect(doc.attributes.title).to.equal('changing the test title')
          done()

    it 'can overwrite a doc without even loading it', (done) ->
      unless TESTGUID
        done()
      else
        doc = @sdk.newDoc('pmpcore')
        doc.attributes.guid = TESTGUID
        doc.attributes.title = 'overwrite the test document'
        doc.attributes.tags = [TESTTAG]
        doc.save true, (doc, resp) ->
          expect(resp).to.be.a.response(200)
          expect(doc.attributes.guid).to.equal(TESTGUID)
          expect(doc.attributes.title).to.equal('overwrite the test document')
          expect(doc.links).to.have.property('profile')
          expect(doc.links.profile[0].href).to.include('profiles/pmpcore')
          done()

  after (done) ->
    @sdk.queryDocs {tag: TESTTAG, writeable: true}, (query) ->
      total = query.items.length
      done() if total == 0
      _.each query.items, (doc) ->
        doc.destroy (doc, resp) ->
          total = total - 1
          done() if total == 0
