Cp   = require \child_process
_    = require \lodash
U    = require \util
Log  = require \./log
Args = require \./args
Act  = require \./action
Cfg  = require \./config .load!
Xaw  = require \./x11-active-window

return Log 'No configuration -- bailing' unless Cfg.get!
err <- Xaw.init
return Log err if err

newid   = 1
pending = {}

Xaw.on \changed ->
  log.debug \changed it
  clear-pendings \in it.previous
  clear-pendings \out it.current
  do-actions \out it.previous
  do-actions \in it.current

function clear-pendings direction, state
  return unless state?
  for id, p of pending when p.act.direction is direction and p.wid is state.wid
    log.debug "clear pending[#id]"
    clearTimeout p.timeout
    delete pending[id]

function do-actions direction, state
  for act in Act.find state, direction
    if d = act.delay * 1000
      log.debug "add pending[#newid] = act:#{U.inspect act} wid:#{state.wid}"
      t = setTimeout run-pending, d, newid
      pending[newid++] = act:act, timeout:t, wid:state.wid
    else
      run-command act.command

function run-command
  return Log "dry-run #it" if Args.dry-run
  log.debug it
  err, stdout, stderr <- Cp.exec it
  return Log err if err
  Log stdout if stdout.length
  Log stderr if stderr.length

function run-pending id
  log.debug "run pending[#id]"
  p = pending[id]
  delete pending[id]
  err, state <- Xaw.get-window-state wid = p.wid
  return Log err if err
  return log.debug "window #wid has closed -- aborting" unless state?
  run-command p.act.command
