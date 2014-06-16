Document = require('./document')
url      = require('url')

#
# query result
#
class Query extends Document
  className: 'Query'

  @createEmpty: (url) ->
    new Query
      href: url
      links:
        navigation: [
          {href: url, refs: ['self'], totalitems: 0, totalpages: 0, pagenum: 1}
        ]
      items: []

  # 404's are an empty result
  @load: (syncer, url, callback) ->
    syncer.get url, (resp) =>
      if resp.success
        doc = new @(syncer, resp.radix)
        callback(doc, resp)
      else if resp.status == 404
        doc = Query.createEmpty(url)
        callback(doc, resp)
      else
        callback(null, resp)

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
