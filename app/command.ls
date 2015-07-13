A = require \assert
_ = require \lodash
C = require \./config

module.exports =
  find: (state, direction) ->
    res = []
    return res unless title = state?title
    A direction in <[ in out ]>
    for k, v of C.get! when (act = v[direction])? and r = v.rx.exec title
      log.debug 'found match:' k, v, act #, r
      act = delay:0 command:act if _.isString act
      for submatch, i in r when i > 0
        log.debug "submatch $#i=#submatch"
        act.command .= replace "$#i" submatch
      res.push act
    log.debug 'found commands:' res
    res
