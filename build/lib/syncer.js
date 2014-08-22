var BaseDoc, Syncer, request, responser, _;

_ = require('underscore');

request = require('request');

responser = require('./responser');

BaseDoc = require('../models/base');

Syncer = (function() {
  var configDefaults;

  configDefaults = {
    accept: 'application/vnd.collection.doc+json',
    contenttype: 'application/vnd.collection.doc+json',
    host: 'https://api-foobar.pmp.io',
    clientid: null,
    clientsecret: null,
    debug: false
  };

  function Syncer(config) {
    if (config == null) {
      config = {};
    }
    this._home = null;
    this._homeResp = null;
    this._queue = [];
    this._token = null;
    this._fetchingToken = false;
    this._config = _.defaults(config, configDefaults);
    this._authenticate();
  }

  Syncer.prototype.token = function(callback) {
    return this.home((function(_this) {
      return function() {
        return callback(_this._token);
      };
    })(this));
  };

  Syncer.prototype.home = function(callback) {
    return this._requestOrQueue('home', null, null, callback);
  };

  Syncer.prototype.get = function(url, callback) {
    return this._requestOrQueue('get', url, null, callback);
  };

  Syncer.prototype.post = function(url, data, callback) {
    return this._requestOrQueue('post', url, {
      body: JSON.stringify(data),
      headers: {
        'Content-Type': this._config.contenttype
      }
    }, callback);
  };

  Syncer.prototype.put = function(url, data, callback) {
    return this._requestOrQueue('put', url, {
      body: JSON.stringify(data),
      headers: {
        'Content-Type': this._config.contenttype
      }
    }, callback);
  };

  Syncer.prototype.del = function(url, callback) {
    return this._requestOrQueue('delete', url, null, callback);
  };

  Syncer.prototype._request = function(method, url, params, callback) {
    if (params == null) {
      params = {};
    }
    if (callback == null) {
      callback = null;
    }
    if (method === 'home') {
      return callback(this._home, this._homeResp);
    } else {
      params = this._getRequestParams(method, url, params);
      params.callback = responser.http(callback);
      if (this._config.debug) {
        params.callback = this._debugCallback(params, params.callback);
      }
      return request(params);
    }
  };

  Syncer.prototype._getRequestParams = function(method, url, params) {
    params.method = method.toUpperCase();
    params.url = url;
    if (params.auth === false) {
      delete params.auth;
    } else if (this._token) {
      params.auth = {
        bearer: this._token
      };
    } else if (this._config.clientid && this._config.clientsecret) {
      params.auth = {
        user: this._config.clientid,
        pass: this._config.clientsecret
      };
    }
    params.json = true;
    params.headers = _.defaults(params.headers || {}, {
      Accept: this._config.accept
    });
    return params;
  };

  Syncer.prototype._retryCallback = function(args, originalCallback) {
    return (function(_this) {
      return function(resp) {
        if (resp.status === 401) {
          _this._queue.push(args);
          return _this._authenticate();
        } else {
          return originalCallback(resp);
        }
      };
    })(this);
  };

  Syncer.prototype._debugCallback = function(params, originalCallback) {
    return (function(_this) {
      return function(err, resp, body) {
        if (err) {
          console.log("### ??? - " + params.method + " " + params.url);
          console.log("###       " + err);
        } else {
          console.log("### " + resp.statusCode + " - " + params.method + " " + params.url);
        }
        return originalCallback(err, resp, body);
      };
    })(this);
  };

  Syncer.prototype._requestOrQueue = function(method, url, params, callback) {
    if (params == null) {
      params = {};
    }
    if (callback == null) {
      callback = null;
    }
    if (this._token) {
      return this._request(method, url, params, this._retryCallback(arguments, callback));
    } else {
      this._queue.push(arguments);
      return this._authenticate();
    }
  };

  Syncer.prototype._clearQueue = function(errorResp) {
    var args, _results;
    if (errorResp == null) {
      errorResp = null;
    }
    _results = [];
    while (this._queue.length > 0) {
      args = this._queue.shift();
      if (errorResp) {
        if (_.first(args) === 'home') {
          _results.push(_.last(args)(this._home, this._homeResp));
        } else {
          _results.push(_.last(args)(errorResp));
        }
      } else {
        _results.push(this._request.apply(this, args));
      }
    }
    return _results;
  };

  Syncer.prototype._authenticate = function() {
    if (!this._fetchingToken) {
      this._token = null;
      this._fetchingToken = true;
      return this._fetchHome((function(_this) {
        return function(resp) {
          if (resp.success) {
            return _this._fetchToken(function(resp) {
              _this._fetchingToken = false;
              if (resp.success) {
                _this._token = resp.radix.access_token;
                return _this._clearQueue();
              } else {
                return _this._clearQueue(resp);
              }
            });
          } else {
            _this._fetchingToken = false;
            return _this._clearQueue(resp);
          }
        };
      })(this));
    }
  };

  Syncer.prototype._fetchToken = function(callback) {
    var opts;
    opts = {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'grant_type=client_credentials'
    };
    return this._request('post', this._home.authCreate(), opts, callback);
  };

  Syncer.prototype._fetchHome = function(callback) {
    return this._request('get', this._config.host, {
      auth: false
    }, (function(_this) {
      return function(resp) {
        _this._homeResp = resp;
        if (resp.success) {
          _this._home = new BaseDoc(resp.radix);
          if (!_this._home.authCreate()) {
            resp.success = false;
            resp.status = 500;
            resp.message = 'Home document missing auth token issue link';
          }
        }
        return callback(resp);
      };
    })(this));
  };

  return Syncer;

})();

module.exports = Syncer;
