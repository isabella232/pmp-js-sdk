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

  PmpSdk.prototype.credList = function(uname, pword, callback) {
    var creds;
    creds = new Creds({
      username: uname,
      password: pword,
      host: this.config.host,
      debug: this.config.debug
    });
    return creds.list(callback);
  };

  PmpSdk.prototype.credCreate = function(uname, pword, label, scope, expires, callback) {
    var creds;
    if (scope == null) {
      scope = 'read';
    }
    if (expires == null) {
      expires = 1209600;
    }
    creds = new Creds({
      username: uname,
      password: pword,
      host: this.config.host,
      debug: this.config.debug
    });
    return creds.create(label, scope, expires, callback);
  };

  PmpSdk.prototype.credDestroy = function(uname, pword, id, callback) {
    var creds;
    creds = new Creds({
      username: uname,
      password: pword,
      host: this.config.host,
      debug: this.config.debug
    });
    return creds.destroy(id, callback);
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

  PmpSdk.prototype.createDoc = function(profileGuid, attrs, callback) {
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
          return doc.save(callback, false);
        } else {
          return callback(null, resp);
        }
      };
    })(this));
  };

  PmpSdk.prototype.createProfile = function() {};

  PmpSdk.prototype.createSchema = function() {};

  PmpSdk.prototype.createUpload = function() {};

  PmpSdk.prototype.createUser = function(title, username, password, callback) {
    var data, doc;
    data = {
      attributes: {
        title: title,
        address: [],
        pingbacks: {},
        auth: {
          user: username,
          password: password,
          clients: []
        }
      },
      links: {
        profile: [
          {
            href: "" + this.config.host + "/profiles/user"
          }
        ]
      }
    };
    doc = new Document(this.sync, data);
    return doc.save(callback, true);
  };

  return PmpSdk;

})();

module.exports = PmpSdk;
