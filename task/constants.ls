Assert = require \assert
Shell  = require \shelljs/global

const DIRNAME =
  BUILD: \_build
  DIST : \dist
  TASK : \task
  TEST : \test

root = pwd!

dir =
  BUILD: "#root/#{DIRNAME.BUILD}"
  build:
    DIST: "#root/#{DIRNAME.BUILD}/#{DIRNAME.DIST}"
    TASK: "#root/#{DIRNAME.BUILD}/#{DIRNAME.TASK}"
    TEST: "#root/#{DIRNAME.BUILD}/#{DIRNAME.TEST}"
  ROOT : root
  DIST : "#root/#{DIRNAME.DIST}"
  TASK : "#root/#{DIRNAME.TASK}"
  TEST : "#root/#{DIRNAME.TEST}"

module.exports =
  APPNAME: \awtrig
  dirname: DIRNAME
  dir    : dir

Assert test \-e dir.DIST
Assert test \-e dir.TASK
Assert test \-e dir.TEST
