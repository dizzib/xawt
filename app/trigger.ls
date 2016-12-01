Cp   = require \child_process
U    = require \util
Log  = require \./log   # Log is mocked but global log isn't
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

function add-pending act, wid, key
  secs = act[key] * 1000ms
  log.debug "add pending[#newid] = act:#{U.inspect act} wid:#wid key:#key"
  t = setTimeout run-pending, secs, newid
  pending[newid++] = act:act, timeout:t, wid:wid

function clear-pendings direction, state
  return unless state?
  for id, p of pending when p.act.direction is direction and p.wid is state.wid
    log.debug "clear pending[#id]"
    clearTimeout p.timeout
    delete pending[id]

function do-actions direction, state
  for act in Act.find state, direction
    if act.delay
      add-pending act, state.wid, \delay
    else
      run-command act

function run-command act
  cmd = act.command
  return Log "dry-run #cmd" if Args.dry-run
  log.debug cmd
  err, stdout, stderr <- Cp.exec cmd
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
  run-command p.act
