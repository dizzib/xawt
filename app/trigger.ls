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
  clear-pendings \in it.previous?wid
  clear-pendings \out it.current?wid
  do-actions \out it.previous
  do-actions \in it.current

Xaw.on \closed ->
  log.debug \closed it
  clear-pendings \in it
  clear-pendings \out it

function add-pending act, wid, key
  secs = act[key] * 1000ms
  log.debug "add pending[#newid] = act:#{U.inspect act} wid:#wid key:#key"
  t = setTimeout run-pending, secs, newid
  pending[newid++] = act:act, timeout:t, wid:wid

function clear-pendings direction, wid
  return unless wid?
  for id, p of pending when p.act.direction is direction and p.wid is wid
    log.debug "clear pending[#id]"
    clearTimeout p.timeout
    delete pending[id]

function do-actions direction, state
  for act in Act.find state, direction
    if act.delay
      add-pending act, state.wid, \delay
    else
      run-command act, state.wid

function run-command act, wid
  cmd = act.command
  return Log "dry-run #cmd" if Args.dry-run
  log.debug cmd
  err, stdout, stderr <- Cp.exec cmd
  Log err if err
  Log stdout if stdout?length
  Log stderr if stderr?length
  add-pending act, wid, \retry if err and act.retry

function run-pending id
  log.debug "run pending[#id]"
  p = pending[id]
  delete pending[id]
  err, state <- Xaw.get-window-state wid = p.wid
  return Log err if err
  run-command p.act, wid
