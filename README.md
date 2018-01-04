# PMP Javascript SDK

[![Build Status](https://travis-ci.org/npr/pmp-js-sdk.svg?branch=master)](https://travis-ci.org/npr/pmp-js-sdk)
[![NPM version](https://badge.fury.io/js/pmpsdk.svg)](http://badge.fury.io/js/pmpsdk)

A Node.JS module, providing a javascript API client for the [Public Media Platform](http://publicmediaplatform.org).  Also includes an experimental browser-ready javascript package.

## Installation

Install with the Node.JS package manager [npm](http://npmjs.org/)

```shell
$ npm install pmpsdk
```

or install via git clone:

```shell
$ git clone git://github.com/npr/pmp-js-sdk.git
$ cd pmp-js-sdk
$ npm install
```

## Basic Usage

The [PMP API Docs](http://support.pmp.io/docs) contain several examples of how to use the sdk.  But it goes something like this...

```javascript
var PmpSdk = require('pmpsdk');
var sdk = new PmpSdk({clientid: 'MYID', clientsecret: 'MYSECRET', host: 'https://api.pmp.io'});

sdk.fetchDoc('04224975-e93c-4b17-9df9-96db37d318f3', function(doc, resp) {
  console.log(resp.status);          // 200
  console.log(resp.success);         // true
  console.log(doc.attributes.guid);  // "04224975-e93c-4b17-9df9-96db37d318f3"
  console.log(doc.attributes.title); // "PMP Home Document"

  doc.attributes.title = "Foobar!";
  doc.save(true, function(doc, resp) {
    console.log(resp.status);  // 403 - since i can't write to the home doc
    console.log(resp.success); // false
  });
});
```

## Interface

### Constructor

The `PmpSdk` constructor simply takes an object of configuration options.

```javascript
var sdk = new PmpSdk(config);
```

| Key            | Required | Description |
| -------------- | -------- | ----------- |
| `host`         | Yes      | The URL of the API to use; `https://api.pmp.io` or `https://api-sandbox.pmp.io`
| `clientid`     | Yes      | Your PMP `client_id`
| `clientsecret` | Yes      | Your PMP `client_secret`
| `debug`        |          | Set to `"1"` or `"2"` to have the SDK `console.log` debug request output.

### HTTP Responses

In many cases, callbacks from the `PmpSdk` will include an "HTTP Response" object, in addition to other return values.  This `resp` will always have the following format:

```javascript
var resp = {
  status: 200,   // the HTTP status code
  success: true, // whether the request succeeded or failed, based on the status
  message: 'OK', // the success or error message of the request
  radix: { /* the json-decoded response body */ }
};
```

### Documents

The `PmpSdk` may also return a `doc` with a response.  This is a javascript class extending the `CollectionDoc+Json` object, with some additional methods allowing you to interact/navigate the PMP.

```javascript
sdk.fetchDoc(SOME_GUID, function(doc, resp) {
  console.log(doc.attributes.title);
  console.log(doc.links.collection);
  console.log(doc.items[0].href);
  doc.followLink(doc.links.creator[0], function(creatorDoc, creatorResp) {
    console.log(creatorDoc.attributes.title);
  });
});
```

Note that all of these callbacks are `function(doc, resp)`:

| Method                              | Description |
| ----------------------------------- | ----------- |
| `refresh(callback)`                 | Reload from the remote source.
| `followLink(urnOrObject, callback)` | Load a linked doc by URN or passing in the link object itself.
| `save(wait, callback)`              | Save the document to the remote source.  If wait is true, the callback `resp.status` will be 200.  Otherwise it will be 202.
| `destroy(callback)`                 | Delete the document.

For "search" responses, there are some additional methods:

| Method            | Description |
| ----------------- | ----------- |
| `total()`         | Return the total number of items on all pages of this search.
| `pages()`         | Return the number of pages in this search.
| `pageNum()`       | Return the current page number.
| `prev(callback)`  | Calls `followLink` for the previous page.
| `next(callback)`  | Calls `followLink` for the next page.
| `first(callback)` | Calls `followLink` for the first page.
| `last(callback)`  | Calls `followLink` for the last page.

To create a new document, you just need to know what profile type you want to create.

```javascript
var doc = sdk.newDoc('story');
doc.attributes.title = 'My story document';
doc.links.alternate = [{href: 'https://foobar.gov'}];
doc.save(true, function(doc, resp) {
  console.log(doc.attributes.guid);    // got auto-assigned a guid!
  console.log(doc.attributes.created); // it's all here!
});
```

Alternatively, you can new-and-save the doc all at once (though currently, you'd have to save it a 2nd time to set any links):

```javascript
var putAttrs = {title: 'My story document', guid: '1234'};
sdk.createDoc('story', putAttrs, true, function(doc, resp) {
  console.log(doc.attributes.guid); // createDoc actually just updated an existing doc!
});
```

### Querying

All these methods for querying the PMP have callbacks of `function(doc, resp)`.  Where `resp` is the usual HTTP Response object, and `doc` is an interactive CollectionDoc represention.  If the `resp` was an error of some sort, `doc` will be null.

| Method                                     | Description |
| ------------------------------------------ | ----------- |
| `fetchHome(callback)`                      | Get the home document.
| `fetchDoc(guid, callback)`                 | Fetch any doc by guid.
| `fetchProfile(alias, callback)`            | Fetch a profile by guid or alias.
| `fetchSchema(alias, callback)`             | Fetch a schema by guid or alias.
| `fetchTopic(alias, callback)`              | Fetch a topic by guid or alias.
| `fetchUser(alias, callback)`               | Fetch a user by guid or alias.
| `queryDocs(params, callback)`              | Search for any doc, with an object [query fields](https://github.com/npr/pmp-docs-wiki/wiki/Querying-the-API#fields).
| `queryCollection(alias, params, callback)` | Search for documents within a collection (by guid or alias).
| `queryGroups(params, callback)`            | Search for groups.
| `queryProfiles(params, callback)`          | Search for profiles.
| `querySchemas(params, callback)`           | Search for schemas.
| `queryTopics(params, callback)`            | Search for topics.
| `queryUsers(params, callback)`             | Search for users.

You can also directly load a document/search by URL:

| Method                    | Description |
| ------------------------- | ----------- |
| `fetchUrl(url, callback)` | Directly load a document
| `queryUrl(url, callback)` | Directly load a search

### Caching across requests

By default, every time you instantiate a `PmpSdk`, it's going to fire off (1) a request for the home document, and (2) a request for an oauth-token for your credential.

To avoid these redundant API calls, you can cache the SDK across request cycles:

```javascript
sdk.serialize(function(str) {
  myCacheThingy.write('pmp-api', str);
});

// ... and then later ...
var cachedSdk = PmpSdk.unserialize(myCacheThingy.read('pmp-api'));
cachedSdk.fetchDoc( /* will only generate 1 request instead of 3 */ );
```

## PMP Proxy

If you just want to explore the PMP, you can also proxy authentication locally.  Make sure you've set the `PMP_HOST` `PMP_CLIENT_ID` and `PMP_CLIENT_SECRET` environment variables.  And BAM!  A click-through-able hypermedia API on http://localhost:8008!

```shell
$ source .env
$ gulp proxy

[10:44:22] Requiring external module coffee-script/register
[10:44:23] Using gulpfile ~/pmp-js-sdk/gulpfile.coffee
[10:44:23] Starting 'proxy'...
[10:44:23] Finished 'proxy' after 175 ms

 ... proxy listening on http://localhost:8008 ...

GET / -> https://api.pmp.io/
GET /docs?profile=story -> https://api.pmp.io/docs?profile=story
```

## Issues and Contributing

Report any bugs or feature-requests via the issue tracker.  Or send me a fax.

Get started contributing by running the tests!  This module is tested/compiled using [gulp.js](http://gulpjs.com/).  Check the `gulpfile.coffee` for the full list of commands.  But to start, you need to set some environment variables:

```shell
export PMP_HOST=https://api-sandbox.pmp.io
export PMP_USERNAME=myusername
export PMP_PASSWORD=test1234
export PMP_CLIENT_ID=THISISABIGSTRING
export PMP_CLIENT_SECRET=ASECRETSTRING
```

I'd recommend only running the tests in the `api-sandbox` environment, as they tend to cause a bit of churn while testing CRUD functionality.  You can also add the above lines to a `.env` file, for easy re-use with a `source .env` command.

Then you can use `gulp` to run the tests, and other tasks:

```shell
$ gulp test       # run all tests
$ gulp build      # compile coffeescript
$ gulp browserify # compile experimental browser js
```

## License

The `pmp-js-sdk` is free software, and may be redistributed under the MIT-LICENSE.

Thanks for listening!
