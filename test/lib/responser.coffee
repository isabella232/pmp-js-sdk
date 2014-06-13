test      = require('../support/test')
expect    = test.expect
responser = test.nocache('../../src/lib/responser')

describe 'responser test', ->

  describe '#http', ->

    it 'translates errors into 500s', ->
      testFn = responser.http (resp) ->
        expect(resp.status).to.equal(500)
        expect(resp.message).to.be
      testFn(new Error('foobar'), null, null)

    it 'gives success for 200-ish codes', ->
      testFn = responser.http (resp) ->
        expect(resp.success).to.be.true
      testFn(null, {statusCode: 200}, null)
      testFn(null, {statusCode: 201}, null)
      testFn(null, {statusCode: 299}, null)

    it 'gives failure for non-200 codes', ->
      testFn = responser.http (resp) ->
        expect(resp.success).to.be.false
      testFn(null, {statusCode: 300}, null)
      testFn(null, {statusCode: 400}, null)
      testFn(null, {statusCode: 404}, null)
      testFn(null, {statusCode: 500}, null)

    it 'auto-populates messages from http status', ->
      testFn = responser.http (resp) ->
        expect(resp.message).to.equal('Payment Required')
      testFn(null, {statusCode: 402}, null)

    it 'returns no radix if the body is not json decodable', ->
      testFn = responser.http (resp) ->
        expect(resp.radix).to.be.null
      testFn(null, {statusCode: 200}, 'foobar')
      testFn(null, {statusCode: 200}, null)
      testFn(null, {statusCode: 200}, undefined)
      testFn(null, {statusCode: 200}, 444)

    it 'returns a radix if the body is json decoded', ->
      testFn = responser.http (resp) ->
        expect(resp.radix).to.be.an('object')
      testFn(null, {statusCode: 200}, {})
      testFn(null, {statusCode: 200}, {foo: 'bar'})
