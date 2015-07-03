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
    log.debug "load config from #{path = Args.config-path}"
    unless test \-e path
      log """Unable to find configuration file #path.
        Please ensure this path is correct and the file exists."""
      return me
    cfg = Yaml.safeLoad Fs.readFileSync path
    cache := {}
    for k, v of cfg
      arr = k.split '/'
      A arr.0.length is 0, 'key must be a regular expression'
      A arr.1.length
      rx = new RegExp arr.1
      cache[rx] = v
    fsw := Fs.watch path, (ev, fname) ->
      me.load! if ev is \change
    me
  reset: -> # for tests
    fsw?close!
    cache := null
