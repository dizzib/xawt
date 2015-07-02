test = it
<- describe 'trigger'
global.log = console.log

A = require \chai .assert
E = require \events .EventEmitter
M = require \mockery

var out, T
var cmd, xaw

after ->
  M.deregisterAll!
  M.disable!
before ->
  M.enable warnOnUnregistered:false
  M.registerMock \child_process exec: -> out.push it
  M.registerMock \./args debug:1
  M.registerMock \./command cmd := {}
  M.registerMock \./x11-active-window xaw := (new E!) with do
    init   : -> it!
    current: {}
  T := require \../app/trigger

beforeEach ->
  out := []
  xaw.removeAllListeners!current.title = ''

test 'focus' ->
  assert ''

function assert then A.equal it, out * ';'
