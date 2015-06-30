_     = require \lodash
Cp    = require \child_process
Shell = require \shelljs/global
Dir   = require \./constants .dir
G     = require \./growl

module.exports.run = (cb) ->
  v = exec 'node --version' silent:true .output - '\n'
  log "run mocha in node #v"
  cmd = "#{Dir.BUILD}/node_modules/mocha/bin/mocha"
  args = "--reporter spec --bail --colors test/**/*.js" / ' '
  output = ''
  Cp.spawn cmd, args, cwd:Dir.BUILD, stdio:[ 0, void, 2 ]
    ..on \exit ->
      tail = output.slice -500
      G.ok "All tests passed\n\n#tail" nolog:true unless it
      G.alert "Tests failed (code=#it)\n\n#tail" nolog:true if it
      return unless _.isFunction cb
      cb if it then new Error "Exited with code #it" else void
    ..stdout.on \data ->
      process.stdout.write it
      output += it.toString!
