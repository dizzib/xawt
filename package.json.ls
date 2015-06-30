name       : \awtrig
version    : \0.1.0
description: "Run shell commands when the active window changes"
keywords   : <[ command exec focus shell X11 ]>
homepage   : \https://github.com/dizzib/awtrig
bugs       : \https://github.com/dizzib/awtrig/issues
license:   : \MIT
author     : \dizzib
bin        : \./bin/awtrig
repository :
  type: \git
  url : \https://github.com/dizzib/awtrig
engines:
  node: '>=0.10.x'
  npm : '>=1.0.x'
dependencies:
  commander  : \2.6.0
  'js-yaml'  : \3.2.5
  livescript : \1.4.0
  lodash     : \3.5.0
  shelljs    : \0.3.0
  x11        : \1.0.3
devDependencies:
  chai       : \~3.0.0
  chalk      : \~0.4.0
  chokidar   : \~1.0.1
  cron       : \~1.0.3
  gntp       : \~0.1.1
  marked     : \~0.3.3
  mocha      : \~2.2.5
  proxyquire : \~1.5.0
  'wait.for' : \~0.6.3
