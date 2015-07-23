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

describe 'sdk serialization', ->

  before (done) ->
    @sdk = new PmpSdk(CFG)
    @sdk.token (token) =>
      expect(token).to.be.a('string')
      @token = token
      @sdk.fetchHome (home, resp) =>
        expect(resp).to.be.a.response(200)
        @home = resp.radix
        done()

  it 'can get an sdk with just the token', (done) ->
    tokenSdk = new PmpSdk(host: CONFIG.host, token: @token, debug: test.debug)
    tokenSdk.fetchProfile 'story', (profile, resp) ->
      expect(resp).to.be.a.response(200)
      expect(profile.href).to.include('story')
      done()

  it 'can get an sdk with the home doc and token', (done) ->
    homeTokenSdk = new PmpSdk(host: CONFIG.host, token: @token, home: @home, debug: test.debug)
    homeTokenSdk.fetchProfile 'story', (profile, resp) ->
      expect(resp).to.be.a.response(200)
      expect(profile.href).to.include('story')
      done()

  it 'can serialize and recover an sdk', (done) ->
    @sdk.serialize (str) =>
      expect(str).to.be.a('string')
      expect(str).to.include(CONFIG.host)
      expect(str).to.include(CONFIG.clientid)
      expect(str).to.include(CONFIG.clientsecret)
      expect(str).to.include(@token)
      expect(str).to.include('PMP Home Document')

      unSdk = PmpSdk.unserialize(str, debug: test.debug)
      unSdk.fetchProfile 'story', (profile, resp) ->
        expect(resp).to.be.a.response(200)
        expect(profile.href).to.include('story')
        done()

  it 'can serialize and recover an sdk with only a token', (done) ->
    homeTokenSdk = new PmpSdk(host: CONFIG.host, token: @token, home: @home, debug: test.debug)
    homeTokenSdk.serialize (str) =>
      expect(str).to.be.a('string')
      expect(str).to.include(CONFIG.host)
      expect(str).to.not.include(CONFIG.clientid)
      expect(str).to.not.include(CONFIG.clientsecret)
      expect(str).to.include(@token)
      expect(str).to.include('PMP Home Document')

      unSdk = PmpSdk.unserialize(str, debug: test.debug)
      unSdk.fetchProfile 'story', (profile, resp) ->
        expect(resp).to.be.a.response(200)
        expect(profile.href).to.include('story')
        done()

  it 'can serialize without including any authorization', (done) ->
    @sdk.serializeTokenOnly (str) =>
      expect(str).to.be.a('string')
      expect(str).to.include(CONFIG.host)
      expect(str).to.not.include(CONFIG.clientid)
      expect(str).to.not.include(CONFIG.clientsecret)
      expect(str).to.include(@token)
      expect(str).to.include('PMP Home Document')

      unSdk = PmpSdk.unserialize(str, debug: test.debug)
      unSdk.fetchProfile 'story', (profile, resp) ->
        expect(resp).to.be.a.response(200)
        expect(profile.href).to.include('story')
        done()

  it 'fails without a token or credentials', (done) ->
    unauthSdk = new PmpSdk(host: CONFIG.host, debug: test.debug)
    unauthSdk.fetchProfile 'story', (profile, resp) ->
      expect(resp).to.be.a.response(401)
      done()

  it 'fails with a home doc and no credentials', (done) ->
    homeOnlySdk = new PmpSdk(host: CONFIG.host, home: @home, debug: test.debug)
    homeOnlySdk.fetchProfile 'story', (profile, resp) ->
      expect(resp).to.be.a.response(401)
      done()

  it 'cannot serialize a bad sdk', (done) ->
    badSdk = new PmpSdk(host: CONFIG.host, debug: test.debug)
    badSdk.serialize (str) =>
      expect(str).to.be.null
      done()
