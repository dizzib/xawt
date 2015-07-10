test = it
<- describe 'trigger'
global.log = console.log

A = require \chai .assert
E = require \events .EventEmitter
M = require \mockery

var out, T
var args, cmd, cfg, xaw

after ->
  M.deregisterAll!
  M.disable!
before ->
  M.enable warnOnUnregistered:false useCleanCache:true
  M.registerMock \child_process exec: (cmd, cb) ->
    out.push cmd
    cb null \stdout \stderr
  M.registerMock \./args args := verbose:0
  M.registerMock \./command cmd := do
    find: ({title}, dirn) -> [command:"#dirn -#c" delay:0 for c in title]
  M.registerMock \./config cfg := load: -> cfg
  M.registerMock \./x11-active-window xaw := (new E!)
beforeEach ->
  out := []
  xaw.removeAllListeners!
  M.resetCache!

test 'bail if missing config' ->
  cfg.get = -> null
  xaw.init = A.fail
  T = require \../app/trigger

run ''   ''   ''
run 'a'  ''   'out -a'
run ''   'b'  'in -b'
run 'a'  'b'  'out -a;in -b'
run 'aA' 'bB' 'out -a;out -A;in -b;in -B'
run 'a'  ''   '' dry-run:true
run 'aA' 'bB' '' dry-run:true

function run pre, cur, expect, opts = dry-run:false
  test "#pre --> #cur" ->
    cfg.get = -> {}
    xaw.init = (cb) -> cb!
    args <<< opts
    T = require \../app/trigger
    xaw.emit \changed do
      current : title:cur
      previous: title:pre
    A.equal expect, out * ';'
