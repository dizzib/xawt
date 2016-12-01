name       : \xawt
version    : \0.1.1
description: "A command-line tool to run shell commands whenever the active window focus changes"
keywords   : <[ command exec focus shell trigger X11 ]>
homepage   : \https://github.com/dizzib/xawt
bugs       : \https://github.com/dizzib/xawt/issues
license:   : \MIT
author     : \dizzib
bin        : \./bin/xawt
repository :
  type: \git
  url : \https://github.com/dizzib/xawt
scripts:
  start: './task/bootstrap && node ./_build/task/repl'
  test : './task/bootstrap && node ./_build/task/npm-test'
dependencies:
  async      : \1.3.0
  commander  : \2.6.0
  leanconf   : \0.2.0
  x11        : \1.0.3
devDependencies:
  chai       : \~3.0.0
  chalk      : \~0.4.0
  chokidar   : \~1.0.1
  cron       : \~1.0.3
  growly     : \~1.3.0
  istanbul   : \~0.3.13
  livescript : \~1.4.0
  lodash     : \~3.5.0
  lolex      : \~1.2.1
  mocha      : \~2.2.5
  mockery    : \~1.4.0
  shelljs    : \~0.3.0
  'wait.for' : \~0.6.3
engines:
  node: '>=0.10.x'
  npm : '>=1.0.x'
preferGlobal: true
