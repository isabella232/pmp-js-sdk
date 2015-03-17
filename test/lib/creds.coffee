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
        expect(resp).to.be.a.response(200)
        done()

    it 'creates credentials', (done) ->
      @goodcreds.create TESTLABEL, null, null, (resp) ->
        expect(resp).to.be.a.response(200)
        expect(resp.radix.label).to.equal(TESTLABEL)
        done()

    it 'destroys credentials', (done) ->
      @goodcreds.create TESTLABEL, null, null, (resp) =>
        expect(resp).to.be.a.response(200)
        @goodcreds.destroy resp.radix.client_id, (dresp) ->
          expect(dresp).to.be.a.response(204)
          done()

  context 'with an invalid login', ->

    it 'fails to list credentials', (done) ->
      @badcreds.list (resp) ->
        expect(resp).to.be.a.response(401)
        expect(resp.radix.errors).to.be.an('object')
        expect(resp.radix.errors.title).to.equal('Unauthorized')
        done()

  context 'with an invalid api location', ->

    it 'fails to find the server', (done) ->
      @badserver.list (resp) ->
        expect(resp).to.be.a.response(500)
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
