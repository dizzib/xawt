test = it
<- describe 'trigger'

A = require \chai .assert
E = require \events .EventEmitter
_ = require \lodash
L = require \lolex
M = require \mockery

var clock, out
var args, act, cfg, xaw

after ->
  clock.uninstall!
  M.deregisterAll!
  M.disable!
before ->
  clock := L.install global
  M.enable warnOnUnregistered:false useCleanCache:true
  M.registerMock \child_process exec: (cmd, cb) ->
    return cb new Error cmd if _.endsWith cmd, \B
    if _.endsWith cmd, \b then cb null '' cmd else cb null, cmd, ''
  M.registerMock \./args args := {}
  M.registerMock \./action act := {}
  M.registerMock \./config cfg := load:->cfg
  M.registerMock \./log -> out.push it
  M.registerMock \./x11-active-window xaw := (new E!)
beforeEach ->
  clock.reset!
  xaw.removeAllListeners!
  M.resetCache!
  args.dry-run = false
  cfg.get = -> {}
  xaw.init = -> it!
  out := []

test 'bail if missing config' ->
  cfg.get = -> null
  xaw.init = A.fail # did not bail
  require \../app/trigger

test 'bail if Xaw.init fails' ->
  xaw.init = -> it \err
  require \../app/trigger
  act.find = ({title}) -> [command:title delay:0]
  emit \a \b
  assert-out \err

describe 'immediate' ->
  describe 'dry-run' ->
    run 'a'  ''   'dry-run out a' true
    run 'aA' 'bB' 'dry-run out a;dry-run out A;dry-run in b;dry-run in B' true
  describe 'live' ->
    run ''   ''   ''
    run 'a'  ''   'out a'
    run ''   'b'  'in b'
    run 'a'  'b'  'out a;in b'
    run 'aA' 'bB' 'out a;out A;in b;Error: in B'

  function run pre, cur, expect, dry-run = false
    test "#pre --> #cur" ->
      act.find = (s, d) -> [command:"#d #c" delay:0 for c in s.title]
      args.dry-run = dry-run
      require \../app/trigger
      emit pre, cur
      assert-out expect

describe 'delay' ->
  beforeEach ->
    act.find = (s, d) ->
      return [] unless s?
      [command:"#d #{s.title}" delay:s.title, direction:d]

  test 'dry-run' ->
    args.dry-run = true
    require \../app/trigger
    emit 0 10
    assert-after 9 'dry-run out 0'
    assert-after 1 'dry-run out 0;dry-run in 10'

  describe 'live' ->
    beforeEach ->
      require \../app/trigger

    test 'in' ->
      emit 0 10
      assert-after 9 'out 0'
      assert-after 1 'out 0;in 10'

    test 'out' ->
      emit 10 0
      assert-after 9 'in 0'
      assert-after 1 'in 0;out 10'

    test 'multi' ->
      emit 10 5
      assert-after 4 ''
      assert-after 1 'in 5'
      assert-after 4 'in 5'
      assert-after 1 'in 5;out 10'

    test 'close' -> # null state
      emit 10 5
      emit null 0
      assert-after 1 'in 0'

    describe 'cancel' ->
      test 'in' ->
        emit 0 10
        emit 10 0
        assert-after 99 'out 0;in 0;out 10'

      test 'out' ->
        emit 10 0
        emit 0 10
        assert-after 99 'in 0;out 0;in 10'

      test 'multi' ->
        emit 20 10
        emit 10 0
        assert-after 99 'in 0;out 10;out 20'

  function assert-after secs, expect
    clock.tick secs * 1000
    assert-out expect

function assert-out
  A.equal it, out * ';'

function emit pre, cur
  xaw.emit \changed do
    current : title:cur, wid:cur
    previous: title:pre, wid:pre if pre?
