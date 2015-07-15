Assert = require \assert
Asyn   = require \async
Evem   = require \events .EventEmitter
X11    = require \x11

var root, state, x

module.exports = me = (new Evem!) with do
  get-window-state: (wid, cb) ->
    xerr, p <- x.GetProperty 0, wid, x.atoms.WM_NAME, 0, 0, 10000000
    return cb! if xerr?error is 3 # bad window, probably closed -- return null state
    return cb wrap-xerr "x.GetProperty WM_NAME failed (wid=#wid)" xerr if xerr
    title = p.data.toString!
    log.debug "get-window-state(#wid)=#title"
    cb null title:title, wid:wid
  init: (cb) ->
    err, disp <- X11.createClient
    return cb err if err
    root := disp.screen.0.root
    x    := disp.client .on \error -> log.debug it
    xerr <- x.InternAtom false \_NET_ACTIVE_WINDOW
    return cb wrap-xerr "x.InternAtom _NET_ACTIVE_WINDOW failed" xerr if xerr
    x.ChangeWindowAttributes root, eventMask:X11.eventMask.PropertyChange
    q = Asyn.queue worker, 1
    x.on \event -> q.push it, (err) -> log err if err
    err, wid <- get-active-wid
    return cb err if err or not wid
    err, cur <- me.get-window-state wid
    state := current:cur
    cb ...

function get-active-wid cb
  xerr, p <- x.GetProperty 0, root, x.atoms._NET_ACTIVE_WINDOW, 0, 0, 10000000
  return cb wrap-xerr "x.GetProperty _NET_ACTIVE_WINDOW failed" xerr if xerr
  return cb! unless wid = p.data.readUInt32LE 0 # switching desktop returns 0
  cb null wid

function worker task, cb
  return cb! unless task.atom is x.atoms._NET_ACTIVE_WINDOW
  err, wid <- get-active-wid
  return cb err if err or not wid
  Assert state.current.wid, 'state.current.wid'
  return cb! if wid is state.current.wid # dedupe duplicate x11 events race
  err, prev <- me.get-window-state pwid = state.current.wid
  return cb err if err
  state.previous = prev
  err, cur <- me.get-window-state wid
  return cb err if err
  state.current = cur
  me.emit \changed state
  cb!

function wrap-xerr msg, xerr
  (new Error "#msg. #{xerr.message}") with xerr:xerr
