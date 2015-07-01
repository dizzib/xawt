global.log = console.log

A = require \chai .assert
S = require \shelljs/global
Y = require \js-yaml
_ = require \lodash
M = require \mockery
  ..registerMock \./args args = config-path:\/tmp/awtrig-config.yaml debug:0
  ..enable warnOnUnregistered:false
T = require \../app/config

const FOO = \./test/config/foo.yaml
const BAR = \./test/config/bar.yaml

test = it
<- describe 'config'

beforeEach ->
  rm \-f args.config-path

test 'load foo' ->
  prepare \foo
  T.load!
  assert-foo!

test 'load bar' ->
  prepare \bar
  T.load!
  assert-bar!

test 'updating file should auto-reload' (done) ->
  prepare \foo
  T.load!
  assert-foo!
  prepare \bar
  setTimeout ->
    assert-bar!
    done!
  ,5

test 'missing file' ->
  try T.load!
  catch e
  A.instanceOf e, Error

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
  log \assert-bar
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
