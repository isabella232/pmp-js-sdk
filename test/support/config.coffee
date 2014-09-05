#
# attempt to load test configuration, or blow up
#
exports.host         = null
exports.username     = null
exports.password     = null
exports.clientid     = null
exports.clientsecret = null

# first, check for a config.json file
configFile = try require('./config.json')
if configFile
  exports.host = configFile.host if configFile.host
  exports.username = configFile.username if configFile.username
  exports.password = configFile.password if configFile.password
  exports.clientid = configFile.clientid if configFile.clientid
  exports.clientsecret = configFile.clientsecret if configFile.clientsecret

# second, check any ENV variables
exports.host = process.env.PMP_HOST if process.env.PMP_HOST
exports.username = process.env.PMP_USERNAME if process.env.PMP_USERNAME
exports.password = process.env.PMP_PASSWORD if process.env.PMP_PASSWORD
exports.clientid = process.env.PMP_CLIENTID if process.env.PMP_CLIENTID
exports.clientsecret = process.env.PMP_CLIENTSECRET if process.env.PMP_CLIENTSECRET

# explode if we're missing something
missing = []
for key, val of exports
  missing.push(key) unless val
if missing.length > 0
  console.error("ERROR: missing test configs: #{missing.join(',')}")
  console.error('Please provide a valid config.json file or ENV variables!')
  process.exit(1)
