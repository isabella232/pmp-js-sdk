test   = require('../support/test')
_      = test.underscore
expect = test.expect
CONFIG = test.config
Creds  = test.nocache('../../src/lib/creds')

TESTLABEL = 'pmpcreds-test-label'
CREDCFG =
  username: CONFIG.username
  password: CONFIG.password
  host:     CONFIG.host
  debug:    test.debug

describe 'client credentials test', ->

  before ->
    @goodcreds = new Creds(CREDCFG)
    @badcreds  = new Creds(_.defaults({username: 'foobar'}, CREDCFG))
    @badserver = new Creds(_.defaults({host: 'https://api-foobar.pmp.io'}, CREDCFG))

  context 'with a valid login', ->

    it 'lists credentials', (done) ->
      @goodcreds.list (resp) ->
        expect(resp.status).to.equal(200)
        expect(resp.success).to.be.true
        expect(resp.radix).to.be.an('array')
        done()

    it 'creates credentials', (done) ->
      @goodcreds.create TESTLABEL, null, null, (resp) ->
        expect(resp.status).to.equal(200)
        expect(resp.success).to.be.true
        expect(resp.radix).to.be.an('object')
        expect(resp.radix.label).to.equal(TESTLABEL)
        done()

    it 'destroys credentials', (done) ->
      @goodcreds.create TESTLABEL, null, null, (resp) =>
        expect(resp.success).to.be.true
        @goodcreds.destroy resp.radix.client_id, (dresp) ->
          expect(dresp.status).to.equal(204)
          expect(dresp.success).to.be.true
          done()

  context 'with an invalid login', ->

    it 'fails to list credentials', (done) ->
      @badcreds.list (resp) ->
        expect(resp.status).to.equal(401)
        expect(resp.success).to.be.false
        expect(resp.radix).to.be.null
        done()

  context 'with an invalid api location', ->

    it 'fails to find the server', (done) ->
      @badserver.list (resp) ->
        expect(resp.status).to.equal(500)
        done()

  # cleanup
  after (done) ->
    @goodcreds.list (resp) =>
      testids = _.pluck _.where(resp.radix, label: TESTLABEL), 'client_id'
      done() if testids.length == 0
      _.each testids, (id) =>
        @goodcreds.destroy id, (dresp) ->
          testids = _.filter testids, (tid) -> tid != id
          done() if testids.length == 0
