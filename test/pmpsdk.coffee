test    = require('./support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
PmpSdk  = test.nocache('../../src/pmpsdk')

TESTGUID = '3501576e-1fb7-4b67-8628-3347d42666c3'

CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        true

sdk = new PmpSdk(CFG)

describe 'pmpsdk test', ->

  it 'fetches a doc by guid', (done) ->
    sdk.fetchDoc TESTGUID, (doc) ->
      console.log("GOT DOC", doc.href)
      done()

  it 'queries for document by guid', (done) ->
    sdk.queryDocs {guid: TESTGUID}, (doc) ->
      expect(doc.href).to.include(TESTGUID)
      done()

  it 'limits returned documents', (done) ->
    sdk.queryDocs {limit: 6}, (query) ->
      expect(query.items.length).to.equal(6)
      expect(query.total()).to.be.above(6)
      expect(query.pages()).to.be.above(1)
      expect(query.pageNum()).to.equal(1)
      done()

  it 'returns documents as items', (done) ->
    sdk.queryDocs {limit: 4}, (query) ->
      _.each query.items, (doc) ->
        expect(doc.className).to.equal('Document')
      done()

  it 'follows paging links', (done) ->
    sdk.queryDocs {limit: 1}, (query) ->
      query.next (qnext) ->
        expect(query.pageNum()).to.equal(1)
        expect(qnext.pageNum()).to.equal(2)
        expect(query.findHref('next')).to.equal(qnext.href)
        expect(qnext.findHref('prev')).to.equal(query.href)
        expect(query.items[0].href).to.not.equal(qnext.items[0].href)
        done()
