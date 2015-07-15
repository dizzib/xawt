test = it
<- describe 'action.find'

A = require \chai .assert
M = require \mockery

const RULES =
  a:
    rx : /^a/
    in : 'a.in'
    out: 'a.out'
  b:
    rx : /b/
    in : 'b.in'
  c:
    rx : /c/
    out: 'c.out'
  submatch:
    rx : /^(d|e) (\w+)$/
    in :
      command: '$1 $1 foo'
      delay: 0
    out:
      command: '$1 $2 bar'
      delay: 0

var args, cfg, T

after ->
  M.deregisterAll!
  M.disable!
before ->
  M.enable warnOnUnregistered:false
  M.registerMock \./config cfg := get:->RULES
  T := require \../app/action

test 'null state' ->
  A.deepEqual [] T.find null \in

describe 'immediate' ->
  run \in  'a'   <[ a.in ]> <[ a ]>
  run \in  'b'   <[ b.in ]> <[ b ]>
  run \in  'c'   <[ ]> <[ ]>
  run \in  'abc' <[ a.in b.in ]> <[ a b ]>
  run \out 'a'   <[ a.out ]> <[ a ]>
  run \out 'b'   <[ ]> <[ ]>
  run \out 'c'   <[ c.out ]> <[ c ]>
  run \out 'abc' <[ a.out c.out ]> <[ a c ]>

  describe 'submatch substitution and explicit format' ->
    run \in  'd f' ['d d foo'] <[ submatch ]>
    run \out 'e g' ['e g bar'] <[ submatch ]>
    run \out 'e h' ['e h bar'] <[ submatch ]> # test immutability

  function run dirn, title, ecmds, erules
    test "#dirn #title" ->
      expect = for c, i in ecmds
        command  : c
        delay    : 0
        direction: dirn
      A.deepEqual expect, T.find title:title, dirn
