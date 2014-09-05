var Creds, Document, PmpSdk, Query, Syncer, _;

_ = require('underscore');

Creds = require('./lib/creds');

Syncer = require('./lib/syncer');

Document = require('./models/document');

Query = require('./models/query');

PmpSdk = (function() {
  function PmpSdk(config) {
    if (config == null) {
      config = {};
    }
    this.config = config;
    this.sync = new Syncer(config);
  }

  PmpSdk.prototype.credList = function(callback) {
    var creds;
    creds = new Creds({
      username: this.config.username,
      password: this.config.password,
      host: this.config.host,
      debug: this.config.debug
    });
    return creds.list(callback);
  };

  PmpSdk.prototype.credCreate = function(label, scope, expires, callback) {
    var creds;
    if (scope == null) {
      scope = 'read';
    }
    if (expires == null) {
      expires = 1209600;
    }
    creds = new Creds({
      username: this.config.username,
      password: this.config.password,
      host: this.config.host,
      debug: this.config.debug
    });
    return creds.create(label, scope, expires, callback);
  };

  PmpSdk.prototype.credDestroy = function(id, callback) {
    var creds;
    creds = new Creds({
      username: this.config.username,
      password: this.config.password,
      host: this.config.host,
      debug: this.config.debug
    });
    return creds.destroy(id, callback);
  };

  PmpSdk.prototype.token = function(callback) {
    return this.sync.token(callback);
  };

  PmpSdk.prototype.fetchHome = function(callback) {
    return this.sync.home(callback);
  };

  PmpSdk.prototype.fetchDoc = function(guid, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Document.load(_this.sync, home.docFetch(guid), callback);
      };
    })(this));
  };

  PmpSdk.prototype.fetchProfile = function(guid, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Document.load(_this.sync, home.profileFetch(guid), callback);
      };
    })(this));
  };

  PmpSdk.prototype.fetchSchema = function(guid, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Document.load(_this.sync, home.schemaFetch(guid), callback);
      };
    })(this));
  };

  PmpSdk.prototype.fetchUser = function(guid, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Document.load(_this.sync, home.userFetch(guid), callback);
      };
    })(this));
  };

  PmpSdk.prototype.queryDocs = function(params, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Query.load(_this.sync, home.docQuery(params), callback);
      };
    })(this));
  };

  PmpSdk.prototype.queryGroups = function(params, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Query.load(_this.sync, home.groupQuery(params), callback);
      };
    })(this));
  };

  PmpSdk.prototype.queryProfiles = function(params, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Query.load(_this.sync, home.profileQuery(params), callback);
      };
    })(this));
  };

  PmpSdk.prototype.querySchemas = function(params, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Query.load(_this.sync, home.schemaQuery(params), callback);
      };
    })(this));
  };

  PmpSdk.prototype.queryUsers = function(params, callback) {
    return this.sync.home((function(_this) {
      return function(home) {
        return Query.load(_this.sync, home.userQuery(params), callback);
      };
    })(this));
  };

  PmpSdk.prototype.createDoc = function(profileGuid, attrs, wait, callback) {
    if (_.isFunction(wait)) {
      callback = wait;
      wait = false;
    }
    return this.fetchProfile(profileGuid, (function(_this) {
      return function(profile, resp) {
        var data, doc;
        if (resp.success) {
          data = {
            attributes: attrs,
            links: {
              profile: [
                {
                  href: profile.href
                }
              ]
            }
          };
          doc = new Document(_this.sync, data);
          return doc.save(wait, callback);
        } else {
          return callback(null, resp);
        }
      };
    })(this));
  };

  PmpSdk.prototype.createUpload = function() {};

  return PmpSdk;

})();

module.exports = PmpSdk;
