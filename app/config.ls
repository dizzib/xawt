A    = require \assert
Fs   = require \fs
Lc   = require \leanconf
_    = require \lodash
Args = require \./args

var cache, fsw

module.exports = me =
  get : -> cache
  load: ->
    function reload ev, fname
      return unless ev is \change
      log "Reload #path"
      me.load!
    me.reset!
    path = Args.config-path
    try
      log.debug "load config from #path"
      conf = Fs.readFileSync path
    catch e
      return throw e unless e.code is \ENOENT
      log "Unable to find configuration file #path"
      unless Args.is-default-config-path
        log 'Please ensure this path is correct and the file exists.'
        return me
      log "Copying default config to #path"
      Fs.writeFileSync path, conf = Fs.readFileSync "#__dirname/default.conf"
    cfg = Lc.parse conf
    cache := {}
    for k, v of cfg
      if (key = k.split '/').0.length or not key.1.length or key.2.length
        throw new Error "key #k must be /regex/"
      cache[k] = v <<< rx:new RegExp key.1
    # some text editors write multiple times, so we must debounce
    fsw := Fs.watch path, _.debounce reload, 100ms, leading:false trailing:true
    me
  reset: -> # for tests
    fsw?close!
    cache := null
