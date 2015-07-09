test = it
<- describe 'x11-active-window'

Asy = require \async
A   = require \chai .assert
E   = require \events .EventEmitter
_   = require \lodash
M   = require \mockery

var names, out, T, x11
disp = client:(x = new E!), screen:[root = 999]
delay = (ms, fn) -> _.delay fn, ms

after ->
  M.deregisterAll!
  M.disable!
before ->
  global.log.debug = if 0 then console.log else ->
  M.enable warnOnUnregistered:false useCleanCache:true
  M.registerMock \x11 x11 := eventMask:{}
beforeEach ->
  names := <[ null red blue green ]>
  out := []
  x.removeAllListeners!
  M.resetCache!
  T := require \../app/x11-active-window
  T.on \changed ->
    function codify state then if state then "#{state.wid}:#{state.title}" else ':'
    out.push "#{codify it.previous}->#{codify it.current}"

function init-x11 spec
  x11.createClient = (cb) -> cb spec.cc?err, disp
  x.atoms = _NET_ACTIVE_WINDOW:1 WM_NAME:2
  x.ChangeWindowAttributes = ->
  x.InternAtom = (,, cb) -> cb spec.ia?err
  mock-gp spec

function mock-gp spec
  x.GetProperty = (, wid, atom,,,, cb) -> delay 2 -> switch atom
    | x.atoms._NET_ACTIVE_WINDOW => cb (r = spec.gpw)?err, data:readUInt32LE:->r
    | x.atoms.WM_NAME =>
      cb (if _.isObject(o = names[wid]) then o else spec.gpn?err), data:names[wid]

eq  = A.equal
eqo = -> eq out * \; it
deq = A.deepEqual

describe 'init' ->
  describe 'error handing' ->
    test-init 'x11.createClient' \err cc:err:new Error \err
    test-init 'x.InternAtom' 'x.InternAtom _NET_ACTIVE_WINDOW failed. err' ia:err:message:\err
    test-init 'x.GetProperty AW' 'x.GetProperty _NET_ACTIVE_WINDOW failed. err' gpw:err:message:\err
    test-init 'x.GetProperty WN' 'x.GetProperty WM_NAME failed (wid=1). err' gpw:1 gpn:err:message:\err
  test-init 'x.GetProperty AW returns 0' void gpw:0
  test-init 'success' {title:\red wid:1} gpw:1

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

describe 'active-window change' ->
  test-aw-change 'not _NET_ACTIVE_WINDOW change' '' -1 [0]
  test-aw-change 'x.GetProperty AW returns 0' '' 1 [0]
  test-aw-change 'x.GetProperty AW returns error' '' 1 [\err]
  test-aw-change '->2' '1:red->2:blue' 1 [2]
  test-aw-change '->2 ->2 should dedupe' '1:red->2:blue' 1 [2 2]
  test-aw-change '->2 ->3' '1:red->2:blue;2:blue->3:green' 1 [2 3]

  function test-aw-change desc, expect, atom, seq
    test desc, (done) ->
      init-x11 gpw:1
      <- T.init
      <- Asy.eachSeries seq, (wid, cb) ->
        mock-gp gpw: if wid is \err then err:message:\errmsg else wid
        x.emit \event atom:atom
        delay 5 cb
      <- delay 50
      eqo expect
      done!

describe 'current window changed in background' ->
  test-bg-change 'change title' '1:red->2:blue;2:cyan->3:green' \cyan
  test-bg-change 'close window' '1:red->2:blue;:->3:green' error:3 message:'bad window'
  test-bg-change 'x11 error' '1:red->2:blue' error:1 message:\errmsg

  function test-bg-change desc, expect, spec
    test desc, (done) ->
      function set-aw wid, cb
        mock-gp gpw:wid
        x.emit \event atom:1
        delay 20 cb
      init-x11 gpw:1
      <- T.init
      <- set-aw 2
      names.2 = spec
      <- set-aw 3
      eqo expect
      done!
