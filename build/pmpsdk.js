// ==============================================================
//  v0.0.0
// Javascript api client for the Public Media Platform
// 
// ==============================================================
// Copyright (c) 2014 cavis <r@cav.is> (http://cav.is)
// Licensed under http:#en.wikipedia.org/wiki/MIT_License
// ==============================================================
(function() {
  var PmpCreds, Requester;

  Requester = require('./lib/requester');

  PmpCreds = (function() {
    function PmpCreds(config) {
      if (config == null) {
        config = {};
      }
      if (!config.username) {
        console.error('username is required');
      }
      if (!config.password) {
        console.error('password is required');
      }
      this.requester = new Requester({
        basicauth: {
          username: config.username,
          password: config.password
        },
        apiread: config.apiread,
        apiwrite: config.apiwrite,
        debug: config.debug
      });
    }

    PmpCreds.prototype.list = function(callback) {
      return this.requester.get('/auth/credentials', function(resp) {
        if (resp.radix) {
          resp.radix = resp.radix.clients;
        }
        return callback(resp);
      });
    };

    PmpCreds.prototype.create = function(label, scope, expires, callback) {
      var data;
      if (scope == null) {
        scope = 'read';
      }
      if (expires == null) {
        expires = 1209600;
      }
      data = {
        label: label,
        scope: scope,
        token_expires_in: expires
      };
      return this.requester.post('/auth/credentials', data, callback);
    };

    PmpCreds.prototype.destroy = function(id, callback) {
      return this.requester.del("/auth/credentials/" + id, callback);
    };

    return PmpCreds;

  })();

  module.exports = PmpCreds;

}).call(this);

