global.log = console.log
Args = require \./args
global.log.debug = if Args.debug then console.log else ->

Cp   = require \child_process
Cmd  = require \./command
Xaw  = require \./x11-active-window

err, info <- Xaw.init
return log err if err

Xaw.on \changed ->
  log Xaw
