global.log = console.log
Args = require \./args
global.log.debug = if Args.debug then console.log else ->

Cp  = require \child_process
Cmd = require \./command
Cfg = require \./config .load!
Xaw = require \./x11-active-window

return log 'No configuration -- bailing' unless Cfg.get!

err <- Xaw.init
return log err if err

Xaw.on \changed ->
  log.debug \changed: Xaw
  run-commands Cmd.find Xaw.previous, \out
  run-commands Cmd.find Xaw.current, \in

function run-commands cmds
  for c in cmds
    log.debug \exec: c
    err, stdout, stderr <- Cp.exec c
    log err if err
    log stdout
    log stderr
