_            = require('underscore')
BaseDocument = require('./base')
responser    = require('../lib/responser')

#
# A document with http capabilities
#
class Document extends BaseDocument
  className: 'Document'

  # load a new doc by url
  @load: (syncer, url, callback) ->
    syncer.get url, (resp) =>
      if resp.success
        doc = new @(syncer, resp.radix)
        callback(doc, resp)
      else
        callback(null, resp)

  # create doc from object
  constructor: (syncer, obj = {}) ->
    @_syncer = syncer
    super(obj)

  # refresh from server
  refresh: (callback) ->
    syncer.get @href, (resp) =>
      if resp.success
        @setData(resp.radix)
        callback(@, resp)
      else
        @setData(null)
        callback(null, resp)

  # recursively process items as docs
  setData: (obj) ->
    super(obj)
    @items = _.map @items, (item) => new Document(@_syncer, item)

  # follow a link to another doc
  followLink: (urnOrObject, callback) ->
    if _.isObject(urnOrObject)
      @constructor.load(@_syncer, urnOrObject.href, callback)
    else if link = @findHref(urnOrObject)
      @constructor.load(@_syncer, link, callback)
    else
      callback(null, responser.error("Unknown link: #{urnOrObject}"))

# class export
module.exports = Document
