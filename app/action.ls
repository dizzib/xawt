A = require \assert
_ = require \lodash
C = require \./config

module.exports =
  find: (state, direction) ->
    res = []
    return res unless title = state?title
    A direction in <[ in out ]>
    for id, rule of _.cloneDeep C.get! when (act = rule[direction])? and r = rule.rx.exec title
      log.debug 'found match:' id, rule, act
      act = delay:0 command:act if typeof act is \string
      for submatch, i in r when i > 0
        log.debug "submatch $#i=#submatch"
        act.command .= replace (new RegExp "\\$#i" \g), submatch
      res.push act <<< direction:direction
    log.debug 'found commands:' res
    res
