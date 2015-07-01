global.log = console.log

A = require \chai .assert
E = require \events .EventEmitter
M = require \mockery
  ..registerMock \child_process exec: -> out.push it
  ..registerMock \./args config-path:\./config.yaml debug:0
  ..registerMock \./x11-active-window xaw = (new E!) with do
    init   : -> it!
    current: {}
  ..enable warnOnUnregistered:false
T = require \../app/trigger

test = it
<- describe 'trigger'

out  = []

beforeEach ->
  out := []
  xaw.removeAllListeners!current.title = ''

test 'focus' ->
  assert ''

function assert then A.equal it, out * ';'
