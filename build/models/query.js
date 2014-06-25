var Document, Query, nodeurl,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Document = require('./document');

nodeurl = require('url');

Query = (function(_super) {
  __extends(Query, _super);

  function Query() {
    return Query.__super__.constructor.apply(this, arguments);
  }

  Query.prototype.className = 'Query';

  Query.createEmpty = function(syncer, url) {
    var data;
    data = {
      href: url,
      links: {
        navigation: [
          {
            href: url,
            rels: ['self'],
            totalitems: 0,
            totalpages: 0,
            pagenum: 1
          }
        ]
      },
      items: []
    };
    return new Query(syncer, data);
  };

  Query.load = function(syncer, url, callback) {
    return syncer.get(url, (function(_this) {
      return function(resp) {
        var doc;
        if (resp.success) {
          doc = new _this(syncer, resp.radix);
          return callback(doc, resp);
        } else if (resp.status === 404) {
          doc = Query.createEmpty(syncer, url);
          return callback(doc, resp);
        } else {
          return callback(null, resp);
        }
      };
    })(this));
  };

  Query.prototype.setData = function(obj) {
    Query.__super__.setData.call(this, obj);
    if (this.href) {
      return this.params = nodeurl.parse(this.href, true).query;
    }
  };

  Query.prototype.total = function() {
    return this.findLink('self').totalitems || 0;
  };

  Query.prototype.pages = function() {
    return this.findLink('self').totalpages || 0;
  };

  Query.prototype.pageNum = function() {
    return this.findLink('self').pagenum || 0;
  };

  Query.prototype.prev = function(callback) {
    return this.followLink('prev', callback);
  };

  Query.prototype.next = function(callback) {
    return this.followLink('next', callback);
  };

  Query.prototype.first = function(callback) {
    return this.followLink('first', callback);
  };

  Query.prototype.last = function(callback) {
    return this.followLink('last', callback);
  };

  return Query;

})(Document);

module.exports = Query;
