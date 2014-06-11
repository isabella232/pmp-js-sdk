PmpCreds  = require('./pmpcreds')
PmpSdk    = require('./pmpsdk')

#
# manifest for both the credentials and main pmp api's
#
module.exports =
  sdk:   (config) -> new PmpSdk(config)
  creds: (config) -> new PmpCreds(config)
