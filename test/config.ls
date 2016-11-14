test = it
<- describe 'config'

A = require \chai .assert
S = require \shelljs/global
M = require \mockery

var args, T
deq = A.deepEqual

after ->
  M.deregisterAll!
  M.disable!
before ->
  M.enable warnOnUnregistered:false
  M.registerMock \./args args := config-path:\/tmp/xawt.conf
  T := require \../app/config
beforeEach ->
  T.reset!

function expect then deq T.load!get!, it
function prepare then cp \-f "./test/config/#it.conf" args.config-path
function run id, exp then prepare id; expect exp

describe 'missing' ->
  beforeEach -> rm \-f args.config-path
  test 'with default config-path should copy default.conf' ->
    args.is-default-config-path = true
    expect '/(.*)/':rx:/(.*)/ in:'echo in $1' out:{command:'echo out $1' delay:2}
  test 'with overridden config-path' ->
    args.is-default-config-path = false
    T.load!; A.isNull T.get!

test 'empty' -> run \empty {}
test 'in' -> run \in '/in/': rx:/in/ in:'cmd -in'
test 'out' -> run \out '/out/': rx:/out/ out:'cmd -out'
test 'in out 1' -> run \inout1 '/inout/': rx:/inout/ in:'cmd -in' out:'cmd -out'
test 'in out 2' -> run \inout2 '/in/':{rx:/in/ in:'cmd -in'} '/out/':{rx:/out/ out:'cmd -out'}

test 'updated file should auto-reload' (done) ->
  run \in '/in/': rx:/in/ in:'cmd -in'
  prepare \out
  setTimeout (-> deq T.get!, '/out/': rx:/out/ out:'cmd -out'; done!), 5

describe 'error' ->
  function run id, expect then prepare id; A.throws T.load, expect
  test 'malformed'     -> run \malformed ''
  test 'key not regex' -> run \not-regex 'key foo must be /regex/'

