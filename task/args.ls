C = require \commander

C.option '--reggie-server-port [port]' 'reggie-server listening port for local publish'
C.parse process.argv
C.app-dirs = C.args

module.exports = C
