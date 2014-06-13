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
    @version    = obj.version    || null
    @href       = obj.href       || null
    @attributes = obj.attributes || {}
    @links      = obj.links      || {}
    @items      = obj.items      || []

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

  # common links
  credList:         -> @authCreate().replace(/\/auth\/.*/, '/auth/credentials')
  credCreate:       -> @authDestroy().replace(/\/auth\/.*/, '/auth/credentials')
  credDestroy: (id) -> @authDestroy().replace(/\/auth\/.*/, "/auth/credentials/#{id}")
  authCreate:  -> @findHref('urn:collectiondoc:form:issuetoken')
  authDestroy: -> @findHref('urn:collectiondoc:form:revoketoken')
  guidGenerate: -> @findHref('urn:collectiondoc:query:guids')
  docCreate:        -> @findTpl('urn:collectiondoc:form:documentsave')
  docFetch:  (guid) -> @findTpl('urn:collectiondoc:hreftpl:docs', guid: guid)
  docUpdate: (guid) -> @findTpl('urn:collectiondoc:form:documentsave', guid: guid)
  docQuery: (parms) -> @findTpl('urn:collectiondoc:query:docs', parms)
  profileCreate:        -> @findTpl('urn:collectiondoc:form:profilesave')
  profileFetch:  (guid) -> @findTpl('urn:collectiondoc:hreftpl:profiles', guid: guid)
  profileUpdate: (guid) -> @findTpl('urn:collectiondoc:form:profilesave', guid: guid)
  profileQuery: (parms) -> @findTpl('urn:collectiondoc:query:profiles', parms)
  schemaCreate:        -> @findTpl('urn:collectiondoc:form:schemasa')
  schemaFetch:  (guid) -> @findTpl('urn:collectiondoc:hreftpl:schemas', guid: guid)
  schemaUpdate: (guid) -> @findTpl('urn:collectiondoc:form:schemasave', guid: guid)
  schemaQuery: (parms) -> @findTpl('urn:collectiondoc:query:schemas', parms)
  uploadCreate: -> @findHref('urn:collectiondoc:form:mediaupload')
  groupQuery: (parms) -> @findTpl('urn:collectiondoc:query:groups', parms)
  userQuery: (parms) -> @findTpl('urn:collectiondoc:query:users', parms)

# class export
module.exports = BaseDocument
