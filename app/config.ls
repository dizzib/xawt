A    = require \assert
Fs   = require \fs
Lc   = require \leanconf
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
      cp "#__dirname/default.conf" path
    log.debug "load config from #path"
    cfg = Lc.parse Fs.readFileSync path
    cache := {}
    for k, v of cfg
      if (key = k.split '/').0.length or not key.1.length or key.2.length
        throw new Error "key #k must be /regex/"
      cache[k] = v <<< rx:new RegExp key.1
    fsw := Fs.watch path, (ev, fname) ->
      return unless ev is \change
      log "Reload #path"
      me.load!
    me
  reset: -> # for tests
    fsw?close!
    cache := null
