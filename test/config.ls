test = it
<- describe 'config'
global.log = console.log

A = require \chai .assert
S = require \shelljs/global
Y = require \js-yaml
_ = require \lodash
M = require \mockery

var args, T

after ->
  M.deregisterAll!
  M.disable!
before ->
  global.log.debug = if 0 then console.log else ->
  M.enable warnOnUnregistered:false
  M.registerMock \./args args := config-path:\/tmp/awtrig-config.yaml
  T := require \../app/config

test 'load foo' ->
  prepare \foo
  T.load!
  assert-foo!

test 'load bar' ->
  prepare \bar
  T.load!
  assert-bar!

test 'updated file should auto-reload' (done) ->
  prepare \foo
  T.load!
  assert-foo!
  prepare \bar
  setTimeout ->
    assert-bar!
    done!
  ,5

test 'missing file' ->
  rm \-f args.config-path
  T.load!
  A.isNull T.get!

test 'malformed yaml' ->
  prepare \malformed
  try T.load!
  catch e
  A.instanceOf e, Y.YAMLException

test 'key not regex' ->
  prepare \not-regex
  try T.load!
  catch e
  A.instanceOf e, Error

function assert-bar
  cfg = T.get!
  A.lengthOf _.keys(cfg), 2
  A.equal 'com -1' cfg[/bar/].in
  A.equal 'com -2' cfg[/baz/].out

function assert-foo
  cfg = T.get!
  A.lengthOf _.keys(cfg), 1
  A.equal 'cmd -in' cfg[/foo/].in
  A.equal 'cmd -out' cfg[/foo/].out

function prepare
  cp \-f "./test/config/#it.yaml" args.config-path
