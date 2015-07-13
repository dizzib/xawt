Cp   = require \child_process
Log  = require \./log
Args = require \./args
Act  = require \./action
Cfg  = require \./config .load!
Xaw  = require \./x11-active-window

return log 'No configuration -- bailing' unless Cfg.get!

err <- Xaw.init
return log err if err

Xaw.on \changed ->
  log.debug \changed it
  do-actions Act.find it.previous, \out
  do-actions Act.find it.current, \in

function do-actions acts
  for a in acts
    c = a.command
    if Args.dry-run then return log \dry-run c
    log.debug c
    err, stdout, stderr <- Cp.exec c
    return Log err if err
    Log stdout if stdout.length
    Log stderr if stderr.length
