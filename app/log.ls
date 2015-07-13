global.log = console.log

Args = require \./args
global.log.debug = if Args.verbose then console.log else ->

module.exports = global.log
