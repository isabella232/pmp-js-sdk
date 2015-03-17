#
# attempt to load test configuration, or blow up
#
exports.host         = null
exports.username     = null
exports.password     = null
exports.clientid     = null
exports.clientsecret = null

# check any ENV variables
exports.host = process.env.PMP_HOST if process.env.PMP_HOST
exports.username = process.env.PMP_USERNAME if process.env.PMP_USERNAME
exports.password = process.env.PMP_PASSWORD if process.env.PMP_PASSWORD
exports.clientid = process.env.PMP_CLIENTID if process.env.PMP_CLIENTID
exports.clientsecret = process.env.PMP_CLIENTSECRET if process.env.PMP_CLIENTSECRET

# fallback to allow underscores in client id/secret
exports.clientid = process.env.PMP_CLIENT_ID if process.env.PMP_CLIENT_ID
exports.clientsecret = process.env.PMP_CLIENT_SECRET if process.env.PMP_CLIENT_SECRET

# explode if we're missing something
missing = []
for key, val of exports
  missing.push(key) unless val
if missing.length > 0
  console.error("ERROR: missing test configs: #{missing.join(',')}")
  console.error('Please provide valid ENV variables!')
  process.exit(1)
