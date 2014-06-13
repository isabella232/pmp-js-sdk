BaseDocument = require('./base')

#
# file upload model
#
class File extends BaseDocument

  constructor: (syncer, obj = {}) ->
    @_syncer = syncer
    super(obj)

  save: (callback) ->
    #todo

# class export
module.exports = File
