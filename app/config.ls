A    = require \assert
Fs   = require \fs
Yaml = require \js-yaml
Sh   = require \shelljs/global
Args = require \./args

var cache, fsw

module.exports = me =
  get : -> cache
  load: ->
    me.reset!
    unless test \-e path = Args.config-path
      log "Unable to find configuration file #path"
      unless Args.is-default-config-path
        log 'Please ensure this path is correct and the file exists.'
        return me
      log "Copying default config to #path"
      cp "#__dirname/default-config.yml" path
    log.debug "load config from #path"
    cfg = Yaml.safeLoad Fs.readFileSync path
    cache := {}
    for k, v of cfg
      arr = k.split '/'
      A arr.0.length is 0, 'key must be a regular expression'
      A arr.1.length
      cache[k] = v <<< rx:new RegExp arr.1
    fsw := Fs.watch path, (ev, fname) ->
      return unless ev is \change
      log "Reload #path"
      me.load!
    me
  reset: -> # for tests
    fsw?close!
    cache := null
