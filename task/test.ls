_     = require \lodash
Cp    = require \child_process
Shell = require \shelljs/global
Dir   = require \./constants .dir
G     = require \./growl

const CMD  = "#{Dir.ROOT}/node_modules/.bin/mocha"
const ARGS = '--reporter spec --bail --colors test/**/*.js'

module.exports =
  exec: ->
    exec "#CMD #ARGS"
  run: (cb) ->
    v = exec 'node --version' silent:true .output - '\n'
    log "run mocha in node #v"
    output = ''
    Cp.spawn CMD, (ARGS / ' '), cwd:Dir.BUILD, stdio:[ 0, void, 2 ]
      ..on \exit ->
        tail = output.slice -500
        G.ok "All tests passed\n\n#tail" nolog:true unless it
        G.alert "Tests failed (code=#it)\n\n#tail" nolog:true if it
        return unless _.isFunction cb
        cb if it then new Error "Exited with code #it" else void
      ..stdout.on \data ->
        process.stdout.write it
        output += it.toString!
