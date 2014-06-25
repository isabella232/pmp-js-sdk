_            = require('underscore')
uuid         = require('uuid')
BaseDocument = require('./base')
responser    = require('../lib/responser')

#
# A document with http capabilities
#
class Document extends BaseDocument
  className: 'Document'
  createMaxRequests: 30
  createDelayMS:     1000

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

  # create or update, optionally waiting for 202 to resolve
  save: (callback, wait = false) ->
    @_syncer.home (home) =>
      @attributes.guid = uuid.v4() unless @attributes.guid
      @href = home.docFetch(@attributes.guid) unless @href
      data =
        version:    @version
        attributes: @attributes
        links:      @links
      @_syncer.put home.docUpdate(@attributes.guid), data, (resp) =>
        if resp.success
          if resp.status == 202 && wait == true
            @_pollForDocument(@href, callback)
          else
            @setData(resp.radix) if resp.status != 202
            callback(@, resp)
        else
          callback(null, resp)

  destroy: (callback) ->
    @_syncer.home (home) =>
      @_syncer.del home.docUpdate(@attributes.guid), (resp) =>
        if resp.success
          @href = null
          @attributes.guid = null
          callback(@, resp)
        else
          callback(null, resp)

  ########  ########  #### ##     ##    ###    ######## ########
  ##     ## ##     ##  ##  ##     ##   ## ##      ##    ##
  ##     ## ##     ##  ##  ##     ##  ##   ##     ##    ##
  ########  ########   ##  ##     ## ##     ##    ##    ######
  ##        ##   ##    ##   ##   ##  #########    ##    ##
  ##        ##    ##   ##    ## ##   ##     ##    ##    ##
  ##        ##     ## ####    ###    ##     ##    ##    ########

  # keep trying to GET document, until it appears
  _pollForDocument: (url, callback, attempt = 1) ->
    if attempt > @createMaxRequests
      callback(@, responser.formatResponse(202, "Exceeded #{@createMaxRequests} max request for: #{url}"))
    else
      @_syncer.get url, (resp) =>
        if resp.success
          @setData(resp.radix)
          callback(@, resp)
        else
          boundFn = _.bind(@_pollForDocument, @)
          _.delay(boundFn, @createDelayMS, url, callback, attempt + 1)

# class export
module.exports = Document
