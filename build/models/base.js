var BaseDocument, parser, _;

_ = require('underscore');

parser = require('uri-template');

BaseDocument = (function() {
  BaseDocument.prototype.className = 'BaseDocument';

  function BaseDocument(obj) {
    if (obj == null) {
      obj = {};
    }
    this.setData(obj);
  }

  BaseDocument.prototype.setData = function(obj) {
    this.version = obj.version || '1.0';
    this.href = obj.href || null;
    this.attributes = _.clone(obj.attributes || {});
    this.links = _.clone(obj.links || {});
    return this.items = _.clone(obj.items || []);
  };

  BaseDocument.prototype.findLink = function(urn) {
    var found;
    found = null;
    _.find(this.links, function(linkList, key) {
      return found = _.find(linkList, function(linkDoc) {
        return _.contains(linkDoc.rels, urn);
      });
    });
    return found || null;
  };

  BaseDocument.prototype.findHref = function(urn) {
    var link;
    if (link = this.findLink(urn)) {
      return link['href'] || link['href-template'];
    } else {
      return null;
    }
  };

  BaseDocument.prototype.findTpl = function(urn, params) {
    var href;
    if (href = this.findHref(urn)) {
      return parser.parse(href).expand(params);
    } else {
      return null;
    }
  };

  BaseDocument.prototype.findProfileHref = function() {
    if (this.links.profile && this.links.profile.length > 0) {
      return this.links.profile[0].href;
    } else {
      return null;
    }
  };

  BaseDocument.prototype.credList = function() {
    return this.authCreate().replace(/\/auth\/.*/, '/auth/credentials');
  };

  BaseDocument.prototype.credCreate = function() {
    return this.authDestroy().replace(/\/auth\/.*/, '/auth/credentials');
  };

  BaseDocument.prototype.credDestroy = function(id) {
    return this.authDestroy().replace(/\/auth\/.*/, "/auth/credentials/" + id);
  };

  BaseDocument.prototype.authCreate = function() {
    return this.findHref('urn:collectiondoc:form:issuetoken');
  };

  BaseDocument.prototype.authDestroy = function() {
    return this.findHref('urn:collectiondoc:form:revoketoken');
  };

  BaseDocument.prototype.guidGenerate = function() {
    return this.findHref('urn:collectiondoc:query:guids');
  };

  BaseDocument.prototype.docFetch = function(guid) {
    return this.findTpl('urn:collectiondoc:hreftpl:docs', {
      guid: guid
    });
  };

  BaseDocument.prototype.docUpdate = function(guid) {
    return this.findTpl('urn:collectiondoc:form:documentsave', {
      guid: guid
    });
  };

  BaseDocument.prototype.docQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:docs', parms);
  };

  BaseDocument.prototype.profileFetch = function(guid) {
    return this.findTpl('urn:collectiondoc:hreftpl:profiles', {
      guid: guid
    });
  };

  BaseDocument.prototype.profileUpdate = function(guid) {
    return this.findTpl('urn:collectiondoc:form:profilesave', {
      guid: guid
    });
  };

  BaseDocument.prototype.profileQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:profiles', parms);
  };

  BaseDocument.prototype.schemaFetch = function(guid) {
    return this.findTpl('urn:collectiondoc:hreftpl:schemas', {
      guid: guid
    });
  };

  BaseDocument.prototype.schemaUpdate = function(guid) {
    return this.findTpl('urn:collectiondoc:form:schemasave', {
      guid: guid
    });
  };

  BaseDocument.prototype.schemaQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:schemas', parms).replace('/users', '/schemas');
  };

  BaseDocument.prototype.uploadCreate = function() {
    return this.findHref('urn:collectiondoc:form:mediaupload');
  };

  BaseDocument.prototype.groupQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:groups', parms);
  };

  BaseDocument.prototype.userQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:users', parms);
  };

  return BaseDocument;

})();

module.exports = BaseDocument;
