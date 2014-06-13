BaseDocument = require('./base')

#
# file upload model
#
class Profile extends BaseDocument

  constructor: (syncer, obj = {}) ->
    @_syncer = syncer
    super(obj)

  save: (callback) ->
    #todo

# class export
module.exports = Profile
