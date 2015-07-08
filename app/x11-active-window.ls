Evem = require \events .EventEmitter
X11  = require \x11

var root, x

module.exports = me = (new Evem!) with do
  init: (cb) ->
    me.removeAllListeners!
    err, disp <- X11.createClient
    return cb err if err
    root := disp.screen.0.root
    x    := disp.client .on \error -> log \error it
    err <- x.InternAtom false \_NET_ACTIVE_WINDOW
    return cb wrap-err "x.InternAtom _NET_ACTIVE_WINDOW failed" err if err
    x.ChangeWindowAttributes root, eventMask:X11.eventMask.PropertyChange
    x.on \event ->
      return unless it.atom is x.atoms._NET_ACTIVE_WINDOW
      err, current <- read-active-window-title
      return log err if err
      return unless current?
      return if current.wid is me.current.wid # workaround duplicate events race
      me.previous = me.current
      me.current = current
      me.emit \changed
    err, me.current <- read-active-window-title
    cb ...
  current : title:'' wid:0
  previous: title:'' wid:0

function read-active-window-title cb
  err, p <- x.GetProperty 0, root, x.atoms._NET_ACTIVE_WINDOW, 0, 0, 10000000
  return cb wrap-err "x.GetProperty _NET_ACTIVE_WINDOW failed" err if err
  return cb! unless wid = p.data.readUInt32LE 0 # switching desktop returns 0
  err, p <- x.GetProperty 0, wid, x.atoms.WM_NAME, 0, 0, 10000000
  return cb wrap-err "x.GetProperty WM_NAME failed: wid=#wid" err if err
  title = p.data.toString!
  log.debug "read-active-window-title=#title"
  cb null title:title, wid:wid

function wrap-err msg, err
  new Error "#msg: #err"
