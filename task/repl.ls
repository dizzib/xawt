global.log = console.log

Chalk  = require \chalk
_      = require \lodash
Rl     = require \readline
Shell  = require \shelljs/global
WFib   = require \wait.for .launchFiber
Args   = require \./args
Build  = require \./build
Consts = require \./constants
DirBld = require \./constants .dir.BUILD
Dist   = require \./distribute
Inst   = require \./install
Run    = require \./run
G      = require \./growl
Test   = require \./test

const CHALKS = [Chalk.stripColor, Chalk.yellow, Chalk.red]
const COMMANDS =
  * cmd:'h   ' lev:0 desc:'help    - show commands'         fn:show-help
  * cmd:'i.d ' lev:0 desc:'install - delete node_modules'   fn:Inst.delete-modules
  * cmd:'i.r ' lev:0 desc:'install - refresh node_modules'  fn:Inst.refresh-modules
  * cmd:'b.a ' lev:0 desc:'build   - all'                   fn:Build.all
  * cmd:'b.d ' lev:0 desc:'build   - delete'                fn:Build.delete-files
  * cmd:'b.r ' lev:0 desc:'build   - recycle'               fn:Run.recycle-app
  * cmd:'t   ' lev:0 desc:'test    - run'                   fn:Test.run
  * cmd:'d.lo' lev:1 desc:'distrib - publish to local'      fn:Dist.publish-local
  * cmd:'d.PU' lev:2 desc:'distrib - publish to public npm' fn:Dist.publish-public

max-level = if Args.reggie-server-port then 2 else 0
commands = _.filter COMMANDS, -> it.level <= max-level

config.fatal  = true # shelljs doesn't raise exceptions, so set this process to die on error
#config.silent = true # otherwise too much noise

cd DirBld # for safety, set working directory to build

for c in COMMANDS then c.display = "#{Chalk.bold CHALKS[c.lev] c.cmd} #{c.desc}"

rl = Rl.createInterface input:process.stdin, output:process.stdout
  ..setPrompt "#{Consts.APPNAME} >"
  ..on \line (cmd) ->
    <- WFib
    rl.pause!
    for c in COMMANDS when cmd is c.cmd.trim!
      try c.fn!
      catch e then log e
    rl.resume!
    rl.prompt!

Build.on \built ->
  Dist.prepare!
  err <- Test.run
  return if err
  Run.recycle-app!
Build.start!
Run.recycle-app!

_.delay show-help, 500ms
_.delay (-> rl.prompt!), 750ms

# helpers

function show-help
  for c in COMMANDS then log c.display
