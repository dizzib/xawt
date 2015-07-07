test = it
<- describe 'x11-active-window'

A = require \chai .assert
E = require \events .EventEmitter
_ = require \lodash
M = require \mockery
U = require \util

var out, T, x11
disp = client:(x = new E!), screen:[root = {}]

after ->
  M.deregisterAll!
  M.disable!
before ->
  global.log.debug = if 0 then console.log else ->
  M.enable warnOnUnregistered:false
  M.registerMock \x11 x11 := eventMask:{}
  T := require \../app/x11-active-window
beforeEach ->
  out := []
  x.removeAllListeners!

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
    test-init 'x.GetProperty AW' 'x.GetProperty _NET_ACTIVE_WINDOW failed: err' do
      gp:[err:\err]
    test-init 'x.GetProperty WN' 'x.GetProperty WM_NAME failed: wid=1: err' do
      gp:[p:data:readUInt32LE:->1] ++ [err:\err]
  test-init 'x.GetProperty AW returns 0' void gp:[p:data:readUInt32LE:->0]
  test-init 'success' {title:\red wid:1} gp:[p:data:readUInt32LE:->1] ++ [p:data:\red]

describe 'x11-event' ->
  test-x11-event 'not _NET_ACTIVE_WINDOW change' '' <[ -1 ]>
  test-x11-event 'x.GetProperty AW returns 0' '' <[ 1,0 ]>
  test-x11-event 'x.GetProperty AW returns error' '' <[ 1,err ]>
  test-x11-event '->2' '0:->2:blue' <[ 1,2,blue ]>
  test-x11-event '->2 ->2' '0:->2:blue' <[ 1,2,blue 1,2,blue ]>

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
    T.on \changed ->
      [p, c] = [T.previous, T.current]
      [pw, pt, cw, ct] = [p.wid, p.title, c.wid, c.title]
      out.push "#pw:#pt->#cw:#ct"
      log 'out' out
    for arr in _.map spec, (-> it / \,)
      gp = [p:data:readUInt32LE:->wid = _.parseInt arr.1] ++ [p:data:title = arr.2]
      gp.0.err = \err if arr.1 is \err
      log gp
      init-x11 gp:gp
      x.emit \event atom:atom = _.parseInt arr.0
    eq out * \; expect
    done!
