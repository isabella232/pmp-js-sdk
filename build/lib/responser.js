module.exports = {
  formatResponse: function(status, message, radix) {
    if (status == null) {
      status = 200;
    }
    if (message == null) {
      message = null;
    }
    if (radix == null) {
      radix = null;
    }
    return {
      status: status,
      success: status < 300,
      message: message || module.exports.statusToMessage(status),
      radix: typeof radix === 'object' ? radix : null
    };
  },
  statusToMessage: function(status) {
    switch (status) {
      case 100:
        return 'Continue';
      case 101:
        return 'Switching Protocols';
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 202:
        return 'Accepted';
      case 203:
        return 'Non-Authoritative Information';
      case 204:
        return 'No Content';
      case 205:
        return 'Reset Content';
      case 206:
        return 'Partial Content';
      case 300:
        return 'Multiple Choices';
      case 301:
        return 'Moved Permanently';
      case 302:
        return 'Found';
      case 303:
        return 'See Other';
      case 304:
        return 'Not Modified';
      case 305:
        return 'Use Proxy';
      case 307:
        return 'Temporary Redirect';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 402:
        return 'Payment Required';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 405:
        return 'Method Not Allowed';
      case 406:
        return 'Not Acceptable';
      case 407:
        return 'Proxy Authentication Required';
      case 408:
        return 'Request Time-out';
      case 409:
        return 'Conflict';
      case 410:
        return 'Gone';
      case 411:
        return 'Length Required';
      case 412:
        return 'Precondition Failed';
      case 413:
        return 'Request Entity Too Large';
      case 414:
        return 'Request-URI Too Large';
      case 415:
        return 'Unsupported Media Type';
      case 416:
        return 'Requested range not satisfiable';
      case 417:
        return 'Expectation Failed';
      case 500:
        return 'Internal Server Error';
      case 501:
        return 'Not Implemented';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Time-out';
      case 505:
        return 'HTTP Version not supported';
      default:
        return 'Unknown';
    }
  },
  http: function(callback) {
    if (callback == null) {
      callback = null;
    }
    return function(err, resp, body) {
      if (callback) {
        if (err) {
          return callback(module.exports.formatResponse(500, 'Unknown error'));
        } else {
          return callback(module.exports.formatResponse(resp.statusCode, null, body));
        }
      }
    };
  },
  error: function(message, callback) {
    if (callback == null) {
      callback = null;
    }
    return callback(module.exports.formatResponse(500, message));
  }
};
