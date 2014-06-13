test    = require('../support/test')
expect  = test.expect
BaseDoc = test.nocache('../../src/models/base')

LINKSDATA =
  foo: [
    {title: 'one',   rels: ['urn:one']},
    {title: 'two',   rels: ['urn:something', 'urn:two']}
    {title: 'three', rels: ['urn:something', 'urn:else', 'urn:three']}
  ]
  bar: [
    {title: 'four', rels: ['urn:four']},
    {title: 'five', href: 'http://five', rels: ['urn:five', 'urn:something']}
  ]
  blah: []

doc = new BaseDoc(links: LINKSDATA)

describe 'base document test', ->

  describe '#findLink', ->

    it 'finds links by rels', ->
      link = doc.findLink('urn:four')
      expect(link.title).to.equal('four')

    it 'finds urns in the list', ->
      link = doc.findLink('urn:three')
      expect(link.title).to.equal('three')

    it 'returns the first found link', ->
      link = doc.findLink('urn:something')
      expect(link.title).to.equal('two')

    it 'returns null if no link is found', ->
      link = doc.findLink('urn:nonexists')
      expect(link).to.be.null

  describe '#findHref', ->

    it 'pulls the href from the doc', ->
      href = doc.findHref('urn:five')
      expect(href).to.equal('http://five')

    it 'returns null if no link is found', ->
      href = doc.findHref('urn:nonexists')
      expect(href).to.be.null

