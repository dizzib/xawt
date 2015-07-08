test = it
<- describe 'x11-active-window'

A = require \chai .assert
E = require \events .EventEmitter
_ = require \lodash
M = require \mockery

var T, x11
disp = client:(x = new E!), screen:[root = {}]

after ->
  M.deregisterAll!
  M.disable!
before ->
  global.log.debug = if 0 then console.log else ->
  M.enable warnOnUnregistered:false useCleanCache:true
  M.registerMock \x11 x11 := eventMask:{}
beforeEach ->
  x.removeAllListeners!
  M.resetCache!
  T := require \../app/x11-active-window

function init-x11 spec
  x11.createClient = (cb) -> cb spec.cc?err, disp
  x.atoms = _NET_ACTIVE_WINDOW:1 WM_NAME:2
  x.ChangeWindowAttributes = ->
  x.InternAtom = (a, b, cb) -> cb spec.ia?err
  x.GetProperty = (a, wid, atom, d, e, f, cb) ->
    cb (res = spec.gp[atom - 1])?err, res?p

eq  = A.equal
deq = A.deepEqual

describe 'init' ->
  describe 'error handing' ->
    test-init 'x11.createClient' \err cc:err:new Error \err
    test-init 'x.InternAtom' 'x.InternAtom _NET_ACTIVE_WINDOW failed: err' ia:err:\err
    test-init 'x.GetProperty AW' 'x.GetProperty _NET_ACTIVE_WINDOW failed: err' gp:[err:\err]
    test-init 'x.GetProperty WN' 'x.GetProperty WM_NAME failed: wid=1: err' gp:[p:data:readUInt32LE:->1] ++ [err:\err]
  test-init 'x.GetProperty AW returns 0' void gp:[p:data:readUInt32LE:->0]
  test-init 'success' {title:\red wid:1} gp:[p:data:readUInt32LE:->1] ++ [p:data:\red]

describe 'x11-event' ->
  test-x11-event 'not _NET_ACTIVE_WINDOW change' '' <[ -1 ]>
  test-x11-event 'x.GetProperty AW returns 0' '' <[ 1,0 ]>
  test-x11-event 'x.GetProperty AW returns error' '' <[ 1,err ]>
  test-x11-event '->2' '1:red->2:blue' <[ 1,2,blue ]>
  test-x11-event '->2 ->2 should dedupe' '1:red->2:blue' <[ 1,2,blue 1,2,blue ]>
  test-x11-event '->2 ->3' '1:red->2:blue;2:blue->3:green' <[ 1,2,blue 1,3,green ]>

function test-init desc, expect, spec
  test desc, (done) ->
    init-x11 spec
    err, res <- T.init
    if _.isString expect
      eq err.message, expect
    if _.isObject expect
      A.isNull err
      deq res, expect
    done!

function test-x11-event desc, expect, spec
  test desc, (done) ->
    init-x11 gp:[p:data:readUInt32LE:->1] ++ [p:data:\red]
    <- T.init
    out = []
    T.on \changed ->
      function codify state then "#{state.wid}:#{state.title}"
      out.push "#{codify T.previous}->#{codify T.current}"
    for arr in _.map spec, (-> it / \,)
      gp = [p:data:readUInt32LE:->wid = _.parseInt arr.1] ++ [p:data:title = arr.2]
      gp.0.err = \err if arr.1 is \err
      init-x11 gp:gp
      x.emit \event atom:atom = _.parseInt arr.0
    eq out * \; expect
    done!
