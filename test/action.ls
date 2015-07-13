test = it
<- describe 'action.find'
global.log = console.log

A = require \chai .assert
M = require \mockery

var args, cfg, T

after ->
  M.deregisterAll!
  M.disable!
before ->
  global.log.debug = if 0 then console.log else ->
  M.enable warnOnUnregistered:false
  M.registerMock \./config cfg := do
    get: ->
      a:
        rx : /a/
        in : 'a.in'
        out: 'a.out'
      b:
        rx : /b/
        in : 'b.in'
      c:
        rx : /c/
        out: 'c.out'
      submatch:
        rx : /(hi|good) (\w+)/
        in : '$1 $2 ann'
        out: '$1 $2 bob'
  T := require \../app/action

test 'null state' ->
  A.deepEqual [] T.find null \in

describe 'immediate' ->
  run-in  'a'   <[ a.in ]>
  run-in  'b'   <[ b.in ]>
  run-in  'c'   <[ ]>
  run-in  'abc' <[ a.in b.in ]>
  run-out 'a'   <[ a.out ]>
  run-out 'b'   <[ ]>
  run-out 'c'   <[ c.out ]>
  run-out 'abc' <[ a.out c.out ]>

  describe 'submatch substitution' ->
    run-in  'hi there' ['hi there ann']
    run-out 'good bye' ['good bye bob']

  function run-in  title, expect then run title, expect, \in
  function run-out title, expect then run title, expect, \out

  function run title, expect, direction
    test "#direction #title" ->
      A.deepEqual [delay:0 command:t for t in expect] T.find title:title, direction
