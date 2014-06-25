test    = require('./support/test')
_       = test.underscore
expect  = test.expect
CONFIG  = test.config
PmpSdk  = test.nocache('../../src/pmpsdk')

TESTGUID = '3501576e-1fb7-4b67-8628-3347d42666c3'
TESTTAG  = 'pmp_js_sdk_testcontent'
TESTCRED = null
TESTDOC  =
  version: '1.0'
  attributes:
    title: 'i am a test document'
    tags: [TESTTAG]
  links:
    profile: [{href: "#{CONFIG.host}/profiles/story"}]

CFG =
  clientid:     CONFIG.clientid
  clientsecret: CONFIG.clientsecret
  host:         CONFIG.host
  debug:        false
sdk = new PmpSdk(CFG)

describe 'pmp querying test', ->

  # it 'queries for groups', (done) ->
  #   @timeout(5000)
  #   sdk.queryGroups {writable: true}, (query) ->
  #     console.log "ITEMS=", query.items.length
  #     console.log "TOTAL=", query.total()
  #     expect(true).to.be.true
  #     done()
  # it 'creates a user', (done) ->
  #   @timeout(6000)
    # sdk.createUser 'cavis', 'cavis', 'password', (user) ->
    #   console.log("\nMADE USER", user, "\n")
    #   done()
    # sdk.credCreate CONFIG.username, CONFIG.password, 'mochatests', 'write', null, (resp) ->
    #   expect(resp.status).to.equal(200)
    #   expect(resp.success).to.be.true
    #   expect(resp.radix).to.be.an('object')
    #   done()

# cleanup
# after (done) ->
#   @timeout(6000)
#   sdk.queryDocs {tag: TESTTAG}, (query) ->
#     if query.items.length == 0
#       done()
#     else
#       total = query.items.length
#       _.each query.items, (doc) ->
#         doc.destroy (doc, resp) ->
#           expect(resp.status).to.equal(204)
#           total = total - 1
#           done() if total == 0
