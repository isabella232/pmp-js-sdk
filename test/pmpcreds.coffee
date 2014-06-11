expect   = require('chai').expect
PmpCreds = require('../src/pmpcreds')
CONFIG   = require('./config.json')

#
# test generating credentials for a pmp user
#
goodcreds = new PmpCreds
  username: CONFIG.username
  password: CONFIG.password
  apiread:  CONFIG.apiread
  apiwrite: CONFIG.apiwrite
badcreds  = new PmpCreds
  username: 'foo'
  password: 'bar'
  apiread:  CONFIG.apiread
  apiwrite: CONFIG.apiwrite
badserver = new PmpCreds
  username: CONFIG.username
  password: CONFIG.password
  apiread:  'https://api-foobar.pmp.io'
  apiwrite: 'https://publish-foobar.pmp.io'

# cleanup
TESTLABEL = 'pmpcreds-test-label'
after (done) ->
  goodcreds.list (resp) ->
    testcreds = resp.radix.filter (cred) -> cred.label == TESTLABEL
    testids = testcreds.map (cred) -> cred.client_id
    nukeCred = (id) ->
      goodcreds.destroy id, (dresp) ->
        testids = testids.filter (tid) -> tid != id
        done() if testids.length == 0
    nukeCred id for id in testids

context 'with a valid login', ->

  it 'lists credentials', (done) ->
    goodcreds.list (resp) ->
      expect(resp.status).to.equal(200)
      expect(resp.success).to.be.true
      expect(resp.radix).to.be.an('array')
      done()

  it 'creates credentials', (done) ->
    goodcreds.create TESTLABEL, null, null, (resp) ->
      expect(resp.status).to.equal(200)
      expect(resp.success).to.be.true
      expect(resp.radix).to.be.an('object')
      expect(resp.radix.label).to.equal(TESTLABEL)
      done()

  it 'destroys credentials', (done) ->
    goodcreds.create TESTLABEL, null, null, (resp) ->
      expect(resp.success).to.be.true
      goodcreds.destroy resp.radix.client_id, (dresp) ->
        expect(dresp.status).to.equal(204)
        expect(dresp.success).to.be.true
        done()

context 'with an invalid login', ->

  it 'fails to list credentials', (done) ->
    badcreds.list (resp) ->
      expect(resp.status).to.equal(401)
      expect(resp.success).to.be.false
      expect(resp.radix).to.be.null
      done()

context 'with an invalid api location', ->

  it 'fails to find the server', (done) ->
    badserver.list (resp) ->
      expect(resp.status).to.equal(500)
      done()
