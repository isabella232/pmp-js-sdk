#
# global testing includes
#
chai = require('chai')
chai.use(require('./matchers.coffee'))

module.exports =

  # greatest lib
  underscore: require('underscore')

  # expect-flavored assertions
  expect: chai.expect

  # remote api configuration
  config: require('./config.coffee')

  # debugging?
  debug: process.env['DEBUG'] || false

  # require a module without caching it (for gulp-watching)
  nocache: (module) ->
    delete require.cache[require.resolve(module)]
    require(module)
