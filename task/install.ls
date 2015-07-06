Assert = require \assert
Shell  = require \shelljs/global
W4     = require \wait.for .for
Dir    = require \./constants .dir

module.exports =
  delete-modules: ->
    log "delete-modules #{pwd!}"
    Assert.equal pwd!, Dir.BUILD
    rm '-rf' "./node_modules"

  refresh-modules: ->
    Assert.equal pwd!, Dir.BUILD
    W4 exec, 'npm -v'
    W4 exec, 'npm prune'
    W4 exec, 'npm install'
