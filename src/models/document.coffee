BaseDocument = require('./base')

#
# document model
#
class Document extends BaseDocument

  constructor: (syncer, obj = {}) ->
    @_syncer = syncer
    super(obj)

  save: (callback) ->
    #todo

# class export
module.exports = Document
