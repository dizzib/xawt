A = require \assert
_ = require \lodash
C = require \./config

module.exports =
  find: (state, direction) ->
    res = []
    return res unless title = state?title
    A direction in <[ in out ]>
    for id, rule of C.get! when (act = rule[direction])? and r = rule.rx.exec title
      log.debug 'found match:' id, rule, act #, r
      act = delay:0 command:act if _.isString act
      act._command = act.command
      for submatch, i in r when i > 0
        log.debug "submatch $#i=#submatch"
        act._command .= replace (new RegExp "\\$#i" \g), submatch
      res.push act <<< direction:direction, rx:rule.rx
    log.debug 'found commands:' res
    res
