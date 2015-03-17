test    = require('../support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
Syncer  = test.nocache('../../src/lib/syncer')
BaseDoc = test.nocache('../../src/models/base')

TESTDOC = "#{CONFIG.host}/docs/fabc86a2-4c7a-11e3-8e77-ce3f5508acd9"
SYNCCFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        test.debug

describe 'syncer test', ->

  context 'with a valid client', ->
    sync = new Syncer(SYNCCFG)

    it 'fetches the home document', (done) ->
      sync.home (doc) ->
        expect(doc).to.be
        expect(doc.href).to.match(///#{CONFIG.host}///)
        done()

    it 'gets by url', (done) ->
      sync.get TESTDOC, (resp) ->
        expect(resp.status).to.equal(200)
        expect(resp.success).to.be.true
        expect(resp.radix).to.be.an('object')
        expect(resp.radix.href).to.match(///#{TESTDOC}///)
        done()

    it 'can refresh its own token', (done) ->
      @timeout(4000)
      sync.home (doc) ->
        expect(doc).to.be
        sync._token = 'foobar'
        sync.get TESTDOC, (resp) ->
          expect(resp.status).to.equal(200)
          done()

  context 'with invalid client credentials', ->
    unauthsync = new Syncer(_.defaults({clientid: 'foobar'}, SYNCCFG))

    it 'still got the home document', (done) ->
      unauthsync.home (doc) ->
        expect(doc).to.be.an('object')
        done()

    it 'cannot get other documents', (done) ->
      unauthsync.get TESTDOC, (resp) ->
        expect(resp.status).to.equal(401)
        expect(resp.success).to.be.false
        expect(resp.radix).to.be.an('object')
        done()

  context 'with invalid api host', ->
    badsync = new Syncer(_.defaults({host: 'https://foobar.pmp.io'}, SYNCCFG))

    it 'cannot get the home document', (done) ->
      badsync.home (doc) ->
        expect(doc).to.be.null
        done()

    it 'cannot get other documents', (done) ->
      badsync.get TESTDOC, (resp) ->
        expect(resp.status).to.equal(500)
        expect(resp.success).to.be.false
        expect(resp.radix).to.be.null
        done()

  context 'with missing client credentials', ->
    missingsync = new Syncer(_.pick(SYNCCFG, 'clientid', 'host', 'debug'))

    it 'still got the home document', (done) ->
      missingsync.home (doc) ->
        expect(doc).to.be.an('object')
        done()

    it 'cannot get other documents', (done) ->
      missingsync.get TESTDOC, (resp) ->
        expect(resp.status).to.equal(401)
        expect(resp.success).to.be.false
        expect(resp.radix).to.be.an('object')
        done()
