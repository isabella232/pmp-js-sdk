_ = require('underscore')

#
# PMP base document (does not include any http interactions)
#
# CANNOT be created directly - it is populated by Sync.home
#
class BaseDocument

  constructor: (obj = {}) ->
    @version    = obj.version
    @href       = obj.href
    @attributes = obj.attributes
    @links      = obj.links
    @items      = obj.items

  findLink: (urn) ->
    found = null
    _.find @links, (linkList, key) ->
      found = _.find linkList, (linkDoc) ->
        _.contains linkDoc.rels, urn
    found || null

  findHref: (urn) ->
    link = @findLink(urn)
    if link then link['href'] || link['href-template'] else null

  # TODO: these creds links are hacks
  credList:    -> @authIssue().replace(/\/auth\/.*/, '/auth/credentials')
  credCreate:  -> @authRevoke().replace(/\/auth\/.*/, '/auth/credentials')
  credDestroy: (id) -> @authRevoke().replace(/\/auth\/.*/, "/auth/credentials/#{id}")

  authIssue:  -> @findHref('urn:collectiondoc:form:issuetoken')
  authRevoke: -> @findHref('urn:collectiondoc:form:revoketoken')

  generateGuid: -> @findHref('urn:collectiondoc:query:guids')

  fetchDoc:     -> @findHref('urn:collectiondoc:hreftpl:docs')
  fetchProfile: -> @findHref('urn:collectiondoc:hreftpl:profiles')
  fetchSchema:  -> @findHref('urn:collectiondoc:hreftpl:schemas')

  updateDoc:     -> @findHref('urn:collectiondoc:form:documentsave')
  updateProfile: -> @findHref('urn:collectiondoc:form:profilesave')
  updateSchema:  -> @findHref('urn:collectiondoc:form:schemasave')
  updateUpload:  -> @findHref('urn:collectiondoc:form:mediaupload')

  queryDocs:     -> @findHref('urn:collectiondoc:query:docs')
  queryGroups:   -> @findHref('urn:collectiondoc:query:groups')
  queryProfiles: -> @findHref('urn:collectiondoc:query:profiles')
  querySchemas:  -> @findHref('urn:collectiondoc:query:schemas')
  queryUsers:    -> @findHref('urn:collectiondoc:query:users')

# class export
module.exports = BaseDocument
