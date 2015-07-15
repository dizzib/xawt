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
  cancel-rematching-pendings \in it.previous
  cancel-rematching-pendings \out it.current
  do-actions Act.find it.previous, \out
  do-actions Act.find it.current, \in

function cancel-rematching-pendings direction, state
  return unless state?
  for id, p of pending when p.act.direction is direction and p.act.rx.test state.title
    log.debug "clear pending[#id]"
    clearTimeout p.timeout
    delete pending[id]

function do-actions
  for act in it
    if d = act.delay * 1000
      log.debug "add pending[#newid] = #{U.inspect act}"
      t = setTimeout run-pending, d, newid
      pending[newid++] = act:act, timeout:t
    else
      run-command act._command

function run-command
  return Log "dry-run #it" if Args.dry-run
  log.debug it
  err, stdout, stderr <- Cp.exec it
  return Log err if err
  Log stdout if stdout.length
  Log stderr if stderr.length

function run-pending id
  log.debug "run pending[#id]"
  run-command (p = pending[id]).act._command
  delete pending[id]
