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
    this.attributes = JSON.parse(JSON.stringify(obj.attributes || {}));
    this.links = JSON.parse(JSON.stringify(obj.links || {}));
    return this.items = JSON.parse(JSON.stringify(obj.items || []));
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
    return this.findHref('urn:collectiondoc:form:listcredentials');
  };

  BaseDocument.prototype.credCreate = function() {
    return this.findHref('urn:collectiondoc:form:createcredentials');
  };

  BaseDocument.prototype.credDestroy = function(id) {
    return this.findTpl('urn:collectiondoc:form:removecredentials', {
      client_id: id
    });
  };

  BaseDocument.prototype.authCreate = function() {
    return this.findHref('urn:collectiondoc:form:issuetoken');
  };

  BaseDocument.prototype.authDestroy = function() {
    return this.findHref('urn:collectiondoc:form:revoketoken');
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

  BaseDocument.prototype.docDelete = function(guid) {
    return this.findTpl('urn:collectiondoc:form:documentdelete', {
      guid: guid
    });
  };

  BaseDocument.prototype.docQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:docs', parms);
  };

  BaseDocument.prototype.groupQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:groups', parms);
  };

  BaseDocument.prototype.profileFetch = function(guid) {
    return this.findTpl('urn:collectiondoc:hreftpl:profiles', {
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

  BaseDocument.prototype.schemaQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:schemas', parms);
  };

  BaseDocument.prototype.topicFetch = function(guid) {
    return this.findTpl('urn:collectiondoc:hreftpl:topics', {
      guid: guid
    });
  };

  BaseDocument.prototype.topicQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:topics', parms);
  };

  BaseDocument.prototype.userFetch = function(guid) {
    return this.findTpl('urn:collectiondoc:hreftpl:users', {
      guid: guid
    });
  };

  BaseDocument.prototype.userQuery = function(parms) {
    return this.findTpl('urn:collectiondoc:query:users', parms);
  };

  BaseDocument.prototype.collectionQuery = function(guid, parms) {
    return this.findTpl('urn:collectiondoc:query:collection', _.extend({}, parms, {
      guid: guid
    }));
  };

  BaseDocument.prototype.uploadCreate = function() {
    return this.findHref('urn:collectiondoc:form:mediaupload');
  };

  return BaseDocument;

})();

module.exports = BaseDocument;
