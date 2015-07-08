Asyn = require \async
Evem = require \events .EventEmitter
X11  = require \x11

var root, state, x

module.exports = me = (new Evem!) with do
  init: (cb) ->
    err, disp <- X11.createClient
    return cb err if err
    root := disp.screen.0.root
    x    := disp.client .on \error -> log \error it
    err <- x.InternAtom false \_NET_ACTIVE_WINDOW
    return cb wrap-err "x.InternAtom _NET_ACTIVE_WINDOW failed" err if err
    x.ChangeWindowAttributes root, eventMask:X11.eventMask.PropertyChange
    q = Asyn.queue worker, 1
    x.on \event -> q.push it, (err) -> log err if err
    err, wid <- get-active-wid
    return cb err if err or not wid
    err, cur <- get-window-title wid
    state := current:cur
    cb ...

function get-active-wid cb
  err, p <- x.GetProperty 0, root, x.atoms._NET_ACTIVE_WINDOW, 0, 0, 10000000
  return cb wrap-err "x.GetProperty _NET_ACTIVE_WINDOW failed" err if err
  return cb! unless wid = p.data.readUInt32LE 0 # switching desktop returns 0
  cb null wid

function get-window-title wid, cb
  err, p <- x.GetProperty 0, wid, x.atoms.WM_NAME, 0, 0, 10000000
  return cb wrap-err "x.GetProperty WM_NAME failed: wid=#wid" err if err
  title = p.data.toString!
  log.debug "get-window-title(#wid)=#title"
  cb null title:title, wid:wid

function worker task, cb
  return cb! unless task.atom is x.atoms._NET_ACTIVE_WINDOW
  err, wid <- get-active-wid
  return cb err if err
  return cb! unless wid
  return cb! if wid is state.current.wid # dedupe duplicate x11 events race
  err, state.previous <- get-window-title state.current.wid
  return cb err if err
  err, state.current <- get-window-title wid
  return cb err if err
  me.emit \changed state
  cb!

function wrap-err msg, err
  new Error "#msg: #err"
