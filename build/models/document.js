var BaseDocument, Document, responser, uuid, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('underscore');

uuid = require('uuid');

BaseDocument = require('./base');

responser = require('../lib/responser');

Document = (function(_super) {
  __extends(Document, _super);

  Document.prototype.className = 'Document';

  Document.prototype.createMaxRequests = 30;

  Document.prototype.createDelayMS = 1000;

  Document.load = function(syncer, url, callback) {
    return syncer.get(url, (function(_this) {
      return function(resp) {
        var doc;
        if (resp.success) {
          doc = new _this(syncer, resp.radix);
          return callback(doc, resp);
        } else {
          return callback(null, resp);
        }
      };
    })(this));
  };

  function Document(syncer, obj) {
    if (obj == null) {
      obj = {};
    }
    this._syncer = syncer;
    this._lastMod = obj.attributes ? obj.attributes.modified : null;
    Document.__super__.constructor.call(this, obj);
  }

  Document.prototype.refresh = function(callback) {
    return this._syncer.get(this.href, (function(_this) {
      return function(resp) {
        if (resp.success) {
          _this.setData(resp.radix);
          return callback(_this, resp);
        } else {
          _this.setData(null);
          return callback(null, resp);
        }
      };
    })(this));
  };

  Document.prototype.setData = function(obj) {
    Document.__super__.setData.call(this, obj);
    return this.items = _.map(this.items, (function(_this) {
      return function(item) {
        return new Document(_this._syncer, item);
      };
    })(this));
  };

  Document.prototype.followLink = function(urnOrObject, callback) {
    var link;
    if (_.isObject(urnOrObject)) {
      return this.constructor.load(this._syncer, urnOrObject.href, callback);
    } else if (link = this.findHref(urnOrObject)) {
      return this.constructor.load(this._syncer, link, callback);
    } else {
      return callback(null, responser.error("Unknown link: " + urnOrObject));
    }
  };

  Document.prototype.save = function(wait, callback) {
    if (_.isFunction(wait)) {
      callback = wait;
      wait = false;
    }
    return this._syncer.home((function(_this) {
      return function(home) {
        var data;
        if (!_this.attributes.guid) {
          _this.attributes.guid = uuid.v4();
        }
        if (!_this.href) {
          _this.href = home.docFetch(_this.attributes.guid);
        }
        data = {
          version: _this.version,
          attributes: _.omit(_this.attributes, 'created', 'modified'),
          links: _.omit(_this.links, 'query', 'edit', 'auth', 'navigation', 'creator')
        };
        return _this._syncer.put(home.docUpdate(_this.attributes.guid), data, function(resp) {
          if (resp.success) {
            if (resp.status === 202 && wait === true) {
              return _this._pollForDocument(_this.href, callback);
            } else {
              if (resp.status !== 202) {
                _this.setData(resp.radix);
              }
              return callback(_this, resp);
            }
          } else {
            return callback(null, resp);
          }
        });
      };
    })(this));
  };

  Document.prototype.destroy = function(callback) {
    return this._syncer.home((function(_this) {
      return function(home) {
        return _this._syncer.del(home.docDelete(_this.attributes.guid), function(resp) {
          if (resp.success) {
            _this.href = null;
            _this.attributes.guid = null;
            return callback(_this, resp);
          } else {
            return callback(null, resp);
          }
        });
      };
    })(this));
  };

  Document.prototype._pollForDocument = function(url, callback, attempt) {
    if (attempt == null) {
      attempt = 1;
    }
    if (attempt > this.createMaxRequests) {
      return callback(this, responser.formatResponse(202, "Exceeded " + this.createMaxRequests + " max request for: " + url));
    } else {
      return this._syncer.poll(url, (function(_this) {
        return function(resp) {
          var boundFn;
          if (resp.success && _this._lastMod !== resp.radix.attributes.modified) {
            _this.setData(resp.radix);
            return callback(_this, resp);
          } else {
            boundFn = _.bind(_this._pollForDocument, _this);
            return _.delay(boundFn, _this.createDelayMS, url, callback, attempt + 1);
          }
        };
      })(this));
    }
  };

  return Document;

})(BaseDocument);

module.exports = Document;
