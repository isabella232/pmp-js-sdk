test    = require('../support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
Syncer  = test.nocache('../../src/lib/syncer')
Query   = test.nocache('../../src/models/query')

CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        test.debug

describe 'query test', ->

  before ->
    @sync = new Syncer(CFG)

  it 'returns documents as items', (done) ->
    @sync.home (home) =>
      Query.load @sync, home.docQuery(limit: 4), (query, resp) ->
        _.each query.items, (doc) ->
          expect(doc.className).to.equal('Document')
        done()

  it 'limits returned documents', (done) ->
    @sync.home (home) =>
      Query.load @sync, home.docQuery(limit: 6), (query, resp) ->
        expect(query.items.length).to.equal(6)
        expect(query.total()).to.be.above(6)
        expect(query.pages()).to.be.above(1)
        expect(query.pageNum()).to.equal(1)
        done()

  it 'follows paging links', (done) ->
    @sync.home (home) =>
      Query.load @sync, home.docQuery(limit: 1), (query, resp) ->
        query.next (qnext) ->
          expect(query.pageNum()).to.equal(1)
          expect(qnext.pageNum()).to.equal(2)
          expect(query.findHref('next')).to.equal(qnext.href)
          expect(qnext.findHref('prev')).to.equal(query.href)
          expect(query.items[0].href).to.not.equal(qnext.items[0].href)
          done()

  it 'translates 404s into empty queries', (done) ->
    @sync.home (home) =>
      Query.load @sync, home.docQuery(tag: 'foobar19482'), (query, resp) ->
        expect(query).to.be
        expect(query.total()).to.equal(0)
        expect(query.items.length).to.equal(0)
        done()
