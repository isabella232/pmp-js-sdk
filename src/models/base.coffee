_      = require('underscore')
parser = require('uri-template')

#
# PMP base document (does not include any http interactions)
#
# CANNOT be created directly - it is populated by Sync.home
#
class BaseDocument
  className: 'BaseDocument'

  constructor: (obj = {}) ->
    @setData(obj)

  setData: (obj) ->
    @version    = obj.version    || '1.0'
    @href       = obj.href       || null
    @attributes = JSON.parse(JSON.stringify(obj.attributes || {}))
    @links      = JSON.parse(JSON.stringify(obj.links      || {}))
    @items      = JSON.parse(JSON.stringify(obj.items      || []))

  findLink: (urn) ->
    found = null
    _.find @links, (linkList, key) ->
      found = _.find linkList, (linkDoc) ->
        _.contains linkDoc.rels, urn
    found || null

  findHref: (urn) ->
    if link = @findLink(urn)
      link['href'] || link['href-template']
    else
      null

  findTpl: (urn, params) ->
    if href = @findHref(urn)
      parser.parse(href).expand(params)
    else
      null

  findProfileHref: ->
    if @links.profile && @links.profile.length > 0
      @links.profile[0].href
    else
      null

  # auth links
  credList:         -> @findHref('urn:collectiondoc:form:listcredentials')
  credCreate:       -> @findHref('urn:collectiondoc:form:createcredentials')
  credDestroy: (id) -> @findTpl('urn:collectiondoc:form:removecredentials', client_id: id)
  authCreate:       -> @findHref('urn:collectiondoc:form:issuetoken')
  authDestroy:      -> @findHref('urn:collectiondoc:form:revoketoken')

  # docs and aliases
  docFetch:      (guid) -> @findTpl('urn:collectiondoc:hreftpl:docs', guid: guid)
  docUpdate:     (guid) -> @findTpl('urn:collectiondoc:form:documentsave', guid: guid)
  docDelete:     (guid) -> @findTpl('urn:collectiondoc:form:documentdelete', guid: guid)
  docQuery:     (parms) -> @findTpl('urn:collectiondoc:query:docs', parms)
  groupQuery:   (parms) -> @findTpl('urn:collectiondoc:query:groups', parms)
  profileFetch:  (guid) -> @findTpl('urn:collectiondoc:hreftpl:profiles', guid: guid)
  profileQuery: (parms) -> @findTpl('urn:collectiondoc:query:profiles', parms)
  schemaFetch:   (guid) -> @findTpl('urn:collectiondoc:hreftpl:schemas', guid: guid)
  schemaQuery:  (parms) -> @findTpl('urn:collectiondoc:query:schemas', parms)
  topicFetch:    (guid) -> @findTpl('urn:collectiondoc:hreftpl:topics', guid: guid)
  topicQuery:   (parms) -> @findTpl('urn:collectiondoc:query:topics', parms)
  userFetch:     (guid) -> @findTpl('urn:collectiondoc:hreftpl:users', guid: guid)
  userQuery:    (parms) -> @findTpl('urn:collectiondoc:query:users', parms)

  # oddball - query within a collection
  collectionQuery: (guid, parms) ->
    @findTpl('urn:collectiondoc:query:collection', _.extend({}, parms, guid: guid))

  # file upload
  uploadCreate: -> @findHref('urn:collectiondoc:form:mediaupload')

# class export
module.exports = BaseDocument
