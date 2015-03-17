test    = require('./support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
PmpSdk  = test.nocache('../../src/pmpsdk')

CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        test.debug

describe 'sdk response sizes', ->

  before ->
    @sdk    = new PmpSdk(_.defaults({minimal: false, gzipped: false}, CFG))
    @minsdk = new PmpSdk(_.defaults({minimal: true,  gzipped: false}, CFG))
    @zipsdk = new PmpSdk(_.defaults({minimal: true,  gzipped: true},  CFG))

  describe 'full responses', ->

    it 'returns all links with query results', (done) ->
      @sdk.queryDocs {profile: 'story', limit: 20}, (query, resp) ->
        expect(query.items.length).to.equal(20)
        expect(query.links).to.have.property('query')
        expect(query.links).to.have.property('edit')
        expect(query.links).to.have.property('auth')
        done()

  describe 'minimal responses', ->

    it 'does not return static links', (done) ->
      @minsdk.queryDocs {profile: 'story', limit: 20}, (query, resp) ->
        expect(query.items.length).to.equal(20)
        expect(query.links).to.not.have.property('query')
        expect(query.links).to.not.have.property('edit')
        expect(query.links).to.not.have.property('auth')
        done()

  describe 'gzipped responses', ->

    it 'gets a zipped response', (done) ->
      @zipsdk.queryDocs {profile: 'story', limit: 20}, (query, resp) ->
        expect(query.items.length).to.equal(20)
        expect(query.links).to.not.have.property('query')
        expect(query.links).to.not.have.property('edit')
        expect(query.links).to.not.have.property('auth')
        done()
