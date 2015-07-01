C = require \commander
_ = require \lodash
P = require \path
J = require \./package.json

config-home = process.env.XDG_CONFIG_HOME or P.join process.env.HOME, \.config
config-path = "#config-home/awtrig.yaml"

C.version J.version
C.usage '[Options]'
C.option '-c, --config-path [path]' "path to configuration file (default:#config-path)", config-path
C.option '-d, --debug' 'emit detailed trace for debugging'
C.parse process.argv

module.exports = C
