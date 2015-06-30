Evem    = require \events .EventEmitter
Proxreq = require \proxyquire

A = require \chai .assert
T = Proxreq \../app/trigger do
  \child_process       : exec: -> out.push it
  \./args              : init: -> config-path:\./config.yaml debug:0
  \./x11-active-window : xaw = (new Evem!) with do
    init: -> it!

test = it
out  = []

beforeEach ->
  out := []
  xaw.removeAllListeners!current.title = ''

test 'focus' ->
  assert ''

function assert then A.equal it, out * ';'
