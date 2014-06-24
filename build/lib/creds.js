var BaseDoc, Creds, request, responser, _;

_ = require('underscore');

request = require('request');

responser = require('./responser');

BaseDoc = require('../models/base');

Creds = (function() {
  var configDefaults;

  configDefaults = {
    accept: 'application/json',
    contentType: 'application/x-www-form-urlencoded',
    host: 'https://api-foobar.pmp.io',
    username: null,
    password: null,
    debug: false
  };

  function Creds(config) {
    if (config == null) {
      config = {};
    }
    this._home = null;
    this._config = _.defaults(config, configDefaults);
  }

  Creds.prototype.home = function(callback) {
    if (this._home) {
      return callback(this._home);
    } else {
      return this._request('get', this._config.host, null, (function(_this) {
        return function(resp) {
          if (resp.success) {
            _this._home = new BaseDoc(resp.radix);
            if (!(_this._home.credList() && _this._home.credCreate() && _this._home.credDestroy())) {
              resp.success = false;
              resp.status = 500;
              resp.message = 'Home document missing auth token links';
            }
            return callback(_this._home);
          } else {
            return callback(null, resp);
          }
        };
      })(this));
    }
  };

  Creds.prototype.list = function(callback) {
    return this.home((function(_this) {
      return function(home, errorResp) {
        if (errorResp == null) {
          errorResp = null;
        }
        if (home) {
          return _this._request('get', home.credList(), null, function(resp) {
            if (resp.radix) {
              resp.radix = resp.radix.clients;
            }
            return callback(resp);
          });
        } else {
          return callback(errorResp);
        }
      };
    })(this));
  };

  Creds.prototype.create = function(label, scope, expires, callback) {
    if (scope == null) {
      scope = 'read';
    }
    if (expires == null) {
      expires = 1209600;
    }
    return this.home((function(_this) {
      return function(home, errorResp) {
        var data;
        if (errorResp == null) {
          errorResp = null;
        }
        if (home) {
          data = {
            label: label,
            scope: scope,
            token_expires_in: expires
          };
          return _this._request('post', home.credCreate(), data, callback);
        } else {
          return callback(errorResp);
        }
      };
    })(this));
  };

  Creds.prototype.destroy = function(id, callback) {
    return this.home((function(_this) {
      return function(home, errorResp) {
        if (errorResp == null) {
          errorResp = null;
        }
        if (home) {
          return _this._request('delete', home.credDestroy(id), null, callback);
        } else {
          return callback(errorResp);
        }
      };
    })(this));
  };

  Creds.prototype._request = function(method, url, data, callback) {
    var params;
    if (data == null) {
      data = {};
    }
    if (callback == null) {
      callback = null;
    }
    if (method === 'home') {
      return callback(this._home);
    } else {
      params = this._getRequestParams(method, url, data);
      params.callback = responser.http(callback);
      if (this._config.debug) {
        params.callback = this._debugCallback(params, params.callback);
      }
      return request(params);
    }
  };

  Creds.prototype._getRequestParams = function(method, url, data) {
    var params, serialized;
    params = {
      method: method.toUpperCase(),
      url: url,
      auth: {
        user: this._config.username,
        pass: this._config.password
      },
      json: true,
      headers: {
        'Accept': this._config.accept
      }
    };
    if (!_.isEmpty(data)) {
      serialized = _.map(data, function(v, k) {
        return "" + (encodeURIComponent(k)) + "=" + (encodeURIComponent(v));
      });
      params.body = serialized.join('&');
      params.headers['Content-Type'] = this._config.contentType;
    }
    return params;
  };

  Creds.prototype._debugCallback = function(params, originalCallback) {
    return (function(_this) {
      return function(err, resp, body) {
        if (err) {
          console.log("### ??? - " + params.method + " " + params.url);
        } else {
          console.log("### " + resp.statusCode + " - " + params.method + " " + params.url);
        }
        return originalCallback(err, resp, body);
      };
    })(this);
  };

  return Creds;

})();

module.exports = Creds;
