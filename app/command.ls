A = require \assert
C = require \./config

module.exports =
  find: (state, direction) ->
    res = []
    return res unless title = state?title
    A direction in <[ in out ]>
    for k, v of C.get! when (c = v[direction])? and r = v.rx.exec title
      log.debug 'found match:' k, v, c, r
      for cap, i in r when i > 0
        log.debug 'capture:' i, cap
        c .= replace "@#i" cap
      res.push c
    log.debug 'found commands:' res
    res
