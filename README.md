# PMP Javascript SDK

[![Build Status](https://travis-ci.org/publicmediaplatform/pmp-js-sdk.svg?branch=master)](https://travis-ci.org/publicmediaplatform/pmp-js-sdk)
[![NPM version](https://badge.fury.io/js/pmpsdk.svg)](http://badge.fury.io/js/pmpsdk)

A Node.JS module, providing a javascript API client for the [Public Media Platform](http://publicmediaplatform.org).  Also includes an experimental browser-ready javascript package.

## Installation

Install with the Node.JS package manager [npm](http://npmjs.org/)

```shell
$ npm install pmpsdk
```

or install via git clone:

```shell
$ git clone git://github.com/publicmediaplatform/pmp-js-sdk.git
$ cd pmp-js-sdk
$ npm install
```

## Documentation

The [PMP API Docs](http://support.pmp.io/docs) contain several examples of how to use the sdk.  But it goes something like this...

```javascript
var PmpSdk = require('pmpsdk');
var sdk = new PmpSdk({clientid: 'MYID', clientsecret: 'MYSECRET', host: 'https://api.pmp.io'});

sdk.fetchDoc('04224975-e93c-4b17-9df9-96db37d318f3', (doc, resp) {
  console.log(resp.status);          // 200
  console.log(resp.success);         // true
  console.log(doc.attributes.guid);  // "04224975-e93c-4b17-9df9-96db37d318f3"
  console.log(doc.attributes.title); // "PMP Home Document"
});
```

More detailed docs/examples forthcoming.

## Developing

This module is tested/compiled using [gulp.js](http://gulpjs.com/).  Check the `gulpfile.coffee` for the full list of commands.  But to start, you need to set some environment variables:

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

## License

The `pmp-js-sdk` is free software, and may be redistributed under the MIT-LICENSE.

Thanks for listening!
