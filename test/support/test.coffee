#
# global testing includes
#
module.exports =

  # greatest lib
  underscore: require('underscore')

  # expect-flavored assertions
  expect: require('chai').expect

  # remote api configuration
  config: require('./config.coffee')

  # debugging?
  debug: process.env['DEBUG'] || false

  # require a module without caching it (for gulp-watching)
  nocache: (module) ->
    delete require.cache[require.resolve(module)]
    require(module)
