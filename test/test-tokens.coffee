expect = require('chai').expect
PmpSdk = require('../src/pmpsdk')
CONFIG = require('./config.json')

pmp = new PmpSdk
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  apiread:      CONFIG.apiread
  apiwrite:     CONFIG.apiwrite
  apimedia:     CONFIG.apimedia

describe 'pmp bearer token', ->

  context 'with valid credentials', ->

    it 'gets bearer a token', (done) ->
      pmp.fetch '/', (resp) ->
        expect(resp.success).to.be.true
        expect(pmp.requester.config.auth).to.match(/^Bearer/)
        done()
