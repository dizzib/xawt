test = it
<- describe 'x11-active-window'

A = require \chai .assert
E = require \events .EventEmitter
_ = require \lodash
M = require \mockery

var names, out, T, x11
disp = client:(x = new E!), screen:[root = 999]

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
    function codify state then "#{state.wid}:#{state.title}"
    out.push "#{codify T.previous}->#{codify T.current}"

function init-x11 spec
  x11.createClient = (cb) -> cb spec.cc?err, disp
  x.atoms = _NET_ACTIVE_WINDOW:1 WM_NAME:2
  x.ChangeWindowAttributes = ->
  x.InternAtom = (,, cb) -> cb spec.ia?err
  mock-gp spec

function mock-gp spec
  x.GetProperty = (, wid, atom,,,, cb) -> switch atom
    | x.atoms._NET_ACTIVE_WINDOW => cb (r = spec.gpw)?err, data:readUInt32LE:->r
    | x.atoms.WM_NAME =>
      return cb \err if names[wid] is \err
      cb spec.gpn?err, data:names[wid]

eq  = A.equal
eqo = -> eq out * \; it
deq = A.deepEqual

describe 'init' ->
  describe 'error handing' ->
    test-init 'x11.createClient' \err cc:err:new Error \err
    test-init 'x.InternAtom' 'x.InternAtom _NET_ACTIVE_WINDOW failed: err' ia:err:\err
    test-init 'x.GetProperty AW' 'x.GetProperty _NET_ACTIVE_WINDOW failed: err' gpw:err:\err
    test-init 'x.GetProperty WN' 'x.GetProperty WM_NAME failed: wid=1: err' gpw:1 gpn:err:\err
  test-init 'x.GetProperty AW returns 0' void gpw:0
  test-init 'success' {title:\red wid:1} gpw:1

describe 'x11-event' ->
  test-x11-event 'not _NET_ACTIVE_WINDOW change' '' -1 [0]
  test-x11-event 'x.GetProperty AW returns 0' '' 1 [0]
  test-x11-event 'x.GetProperty AW returns error' '' 1 [\err]
  test-x11-event '->2' '1:red->2:blue' 1 [2]
  test-x11-event '->2 ->2 should dedupe' '1:red->2:blue' 1 [2 2]
  test-x11-event '->2 ->3' '1:red->2:blue;2:blue->3:green' 1 [2 3]

  test 'current title changes in background' (done) ->
    function set-aw wid
      mock-gp gpw:wid
      x.emit \event atom:1
    init-x11 gpw:1
    <- T.init
    set-aw 2
    # test error
    names.2 = \err
    set-aw 3
    eqo '1:red->2:blue'
    # test ok
    names.2 = \cyan
    set-aw 3
    eqo '1:red->2:blue;2:cyan->3:green'
    done!

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

function test-x11-event desc, expect, atom, seq
  test desc, (done) ->
    init-x11 gpw:1
    <- T.init
    for wid in seq
      mock-gp gpw: if wid is \err then err:\err else wid
      x.emit \event atom:atom
    eqo expect
    done!
