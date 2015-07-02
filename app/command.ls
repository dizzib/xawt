A = require \assert
C = require \./config

module.exports =
  find: (win, direction) ->
    A direction in <[ in out ]>
    res = []
    for k, v of C.get! when (c = v[direction])? and r = v.rx.exec win.title
      log.debug 'found match:' k, v, c, r
      for cap, i in r when i > 0
        log.debug 'capture:' i, cap
        c .= replace "@#i" cap
      res.push c
    log.debug 'found commands:' res
    res
