#
# utility for consistent formatting of response objects
#

formatResponse = (status = 200, message = null, radix = null) ->
  status:  status
  success: status < 300
  message: message || statusToMessage(status)
  radix:   if typeof(radix) == 'object' then radix else null

statusToMessage = (status) ->
  switch status
    when 100 then 'Continue'
    when 101 then 'Switching Protocols'
    when 200 then 'OK'
    when 201 then 'Created'
    when 202 then 'Accepted'
    when 203 then 'Non-Authoritative Information'
    when 204 then 'No Content'
    when 205 then 'Reset Content'
    when 206 then 'Partial Content'
    when 300 then 'Multiple Choices'
    when 301 then 'Moved Permanently'
    when 302 then 'Found'
    when 303 then 'See Other'
    when 304 then 'Not Modified'
    when 305 then 'Use Proxy'
    when 307 then 'Temporary Redirect'
    when 400 then 'Bad Request'
    when 401 then 'Unauthorized'
    when 402 then 'Payment Required'
    when 403 then 'Forbidden'
    when 404 then 'Not Found'
    when 405 then 'Method Not Allowed'
    when 406 then 'Not Acceptable'
    when 407 then 'Proxy Authentication Required'
    when 408 then 'Request Time-out'
    when 409 then 'Conflict'
    when 410 then 'Gone'
    when 411 then 'Length Required'
    when 412 then 'Precondition Failed'
    when 413 then 'Request Entity Too Large'
    when 414 then 'Request-URI Too Large'
    when 415 then 'Unsupported Media Type'
    when 416 then 'Requested range not satisfiable'
    when 417 then 'Expectation Failed'
    when 500 then 'Internal Server Error'
    when 501 then 'Not Implemented'
    when 502 then 'Bad Gateway'
    when 503 then 'Service Unavailable'
    when 504 then 'Gateway Time-out'
    when 505 then 'HTTP Version not supported'
    else 'Unknown'

module.exports =

  # respond to http requests
  http: (callback = null) ->
    (err, resp, body) ->
      if callback
        if err
          callback formatResponse(500, 'Unknown error')
        else
          callback formatResponse(resp.statusCode, null, body)

  # respond with a fatal error message
  error: (message, callback = null) ->
    callback formatResponse(500, message)
