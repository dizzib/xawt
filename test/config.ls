test = it
<- describe 'config'

A = require \chai .assert
S = require \shelljs/global
_ = require \lodash
M = require \mockery

var args, T

after ->
  M.deregisterAll!
  M.disable!
before ->
  M.enable warnOnUnregistered:false
  M.registerMock \./args args := config-path:\/tmp/xawt.conf
  T := require \../app/config
beforeEach ->
  T.reset!

deq = A.deepEqual

test 'missing with default config-path should copy default.conf' ->
  args.is-default-config-path = true
  rm \-f args.config-path
  deq T.load!get!, '/(.*)/':
    rx:/(.*)/ in:'echo in $1' out:{command:'echo out $1' delay:2}

test 'missing with overridden config-path' ->
  args.is-default-config-path = false
  rm \-f args.config-path
  T.load!
  A.isNull T.get!

test 'empty' ->
  prepare \empty
  deq T.load!get!, {}

test 'in' ->
  prepare \in
  deq T.load!get!, '/in/': rx:/in/ in:'cmd -in'

test 'out' ->
  prepare \out
  deq T.load!get!, '/out/': rx:/out/ out:'cmd -out'

test 'in out 1' ->
  prepare \inout1
  deq T.load!get!, '/inout/': rx:/inout/ in:'cmd -in' out:'cmd -out'

test 'in out 2' ->
  prepare \inout2
  deq T.load!get!, do
    '/in/' : rx:/in/ in:'cmd -in'
    '/out/': rx:/out/ out:'cmd -out'

test 'updated file should auto-reload' (done) ->
  prepare \in
  deq T.load!get!, '/in/': rx:/in/ in:'cmd -in'
  prepare \out
  setTimeout ->
    deq T.load!get!, '/out/': rx:/out/ out:'cmd -out'
    done!
  ,5

test 'malformed' ->
  prepare \malformed
  A.throws T.load, ''

test 'key not regex' ->
  prepare \not-regex
  A.throws T.load, 'key foo must be /regex/'

function prepare
  cp \-f "./test/config/#it.conf" args.config-path
