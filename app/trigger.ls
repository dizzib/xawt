global.log = console.log
Args = require \./args
global.log.debug = if Args.verbose then console.log else ->

Cp  = require \child_process
Cmd = require \./command
Cfg = require \./config .load!
Xaw = require \./x11-active-window

return log 'No configuration -- bailing' unless Cfg.get!

err <- Xaw.init
return log err if err

Xaw.on \changed ->
  log.debug \changed it
  do-actions Cmd.find it.previous, \out
  do-actions Cmd.find it.current, \in

function do-actions acts
  for a in acts
    c = a.command
    if Args.dry-run then return log \dry-run c
    log.debug c
    err, stdout, stderr <- Cp.exec c
    log err if err
    log stdout if stdout.length
    log stderr if stderr.length
