#
# custom expectation matchers
#
module.exports = (chai) ->

  # response validator
  chai.Assertion.addMethod 'response', (status = 200) ->
    resp = @_obj

    # assert response format
    new chai.Assertion(resp).to.be.an('object')
    new chai.Assertion(resp).to.have.property('status')
    new chai.Assertion(resp).to.have.property('success')
    new chai.Assertion(resp).to.have.property('message')
    new chai.Assertion(resp).to.have.property('radix')

    # assert response status
    data   = JSON.stringify(resp)
    islike = "expected #{data} to be a #{status} response"
    unlike = "expected #{data} to not be a #{status} response"
    @assert(resp.status == status, islike, unlike)

    # check success and message
    if status < 400
      new chai.Assertion(resp.success).to.be.true
    else
      new chai.Assertion(resp.success).to.be.false
    new chai.Assertion(resp.message).to.be.a('string')
