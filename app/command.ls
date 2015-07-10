A = require \assert
C = require \./config

module.exports =
  find: (state, direction) ->
    res = []
    return res unless title = state?title
    A direction in <[ in out ]>
    for k, v of C.get! when (c = v[direction])? and r = v.rx.exec title
      log.debug 'found match:' k, v, c, r
      for submatch, i in r when i > 0
        log.debug "submatch $#i=#submatch"
        c .= replace "$#i" submatch
      res.push c
    log.debug 'found commands:' res
    res
