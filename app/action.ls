A = require \assert
C = require \./config

module.exports =
  find: (state, direction) ->
    res = []
    return res unless title = state?title
    A direction in <[ in out ]>
    for id, rule of C.get! when (act = rule[direction])? and r = rule.rx.exec title
      log.debug 'found match:' id, rule, act
      cmd = act.command or act
      for submatch, i in r when i > 0
        log.debug "submatch $#i=#submatch"
        cmd .= replace (new RegExp "\\$#i" \g), submatch
      res.push command:cmd, delay:(act.delay or 0), direction:direction
    log.debug 'found commands:' res
    res
