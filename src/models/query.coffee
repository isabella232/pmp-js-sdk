Document = require('./document')
url      = require('url')

#
# query result
#
class Query extends Document
  className: 'Query'

  # grab params from the href
  setData: (obj) ->
    super(obj)
    @params = url.parse(@href, true).query if @href

  # search metadata
  total:   -> @findLink('self').totalitems || null
  pages:   -> @findLink('self').totalpages || null
  pageNum: -> @findLink('self').pagenum    || null

  # navigation
  prev:  (callback) -> @followLink('prev', callback)
  next:  (callback) -> @followLink('next', callback)
  first: (callback) -> @followLink('first', callback)
  last:  (callback) -> @followLink('last', callback)

# class export
module.exports = Query
