Assert = require \assert
Asyn   = require \async
Evem   = require \events .EventEmitter
X11    = require \x11

var candidate-for-close-wids, root, state, x

candidate-for-close-wids = {}

module.exports = me = (new Evem!) with do
  get-window-state: (wid, cb) ->
    xerr, p <- x.GetProperty 0, wid, x.atoms.WM_NAME, 0, 0, 10000000
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
    x.ChangeWindowAttributes root, eventMask:X11.eventMask.PropertyChange + X11.eventMask.SubstructureNotify
    err, wid <- get-active-wid
    return cb err if err or not wid
    err, cur <- me.get-window-state wid
    state := current:cur
    q = Asyn.queue worker, 1
    x.on \event -> q.push it, (err) -> log err if err
    cb ...

function get-active-wid cb
  xerr, p <- x.GetProperty 0, root, x.atoms._NET_ACTIVE_WINDOW, 0, 0, 10000000
  return cb wrap-xerr "x.GetProperty _NET_ACTIVE_WINDOW failed" xerr if xerr
  return cb! unless wid = p.data.readUInt32LE 0 # switching desktop returns 0
  candidate-for-close-wids[wid] = true
  cb null wid

function worker task, cb
  switch task.name
    case \PropertyNotify
      return cb! unless task.atom is x.atoms._NET_ACTIVE_WINDOW
      err, wid <- get-active-wid
      return cb err if err or not wid
      return cb! if wid is state.current?wid # dedupe duplicate x11 events race
      err, cur <- me.get-window-state wid
      return cb err if err
      if state.current
        err, prev <- me.get-window-state pwid = state.current.wid
        state.current = cur # always update, even on error
        return cb err if err
        state.previous = prev
        me.emit \changed state
        cb!
      else
        state.current = cur
        state.previous = null
        me.emit \changed state
        cb!
    case \UnmapNotify
      return cb! unless candidate-for-close-wids[wid = task.wid]
      delete candidate-for-close-wids[wid]
      state.current = null if state.current?wid is wid
      me.emit \closed wid
      cb!
    default
      cb!

function wrap-xerr msg, xerr
  (new Error "#msg. #{xerr.message} [#{xerr.error}]") with xerr:xerr
