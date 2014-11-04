# Description:
#   count execution of script automatically.
#
# Commands:
#   hubot <sc> - show script execution count.
#   hubot <sc reset> - remove all count.
#   hubot <sc remove [script]> - remove specified script count.
#   hubot <sc set [script number]> - set specified count to specified script count.
#

module.exports = (robot) ->
  receiveOrg = robot.receive
  robot.receive = (msg) ->
    for listener in robot.listeners
      if listener.regex?test(msg.text)
        script = msg.text?.split(/\s+/)[1]?.trim().toLowerCase()
        key = "script_#{script}"
        if not robot.brain.get(key)
          robot.brain.set(key, 0)
        robot.brain.set(key, robot.brain.get(key) + 1)
        robot.brain.save()
    receiveOrg.bind(robot)(msg)



  robot.respond /\s*sc\s*$/i, (msg) ->
    script_obj = eval(robot.brain.data["_private"])
    result = ""
    for script of script_obj
      scriptName = /^script_([a-zA-Z0-9-_]+)\s*$/.exec(script)?[1]
      if scriptName?
        result += scriptName + " : " + script_obj[script] + "\n"
    msg.send result



  robot.respond /\s*sc\s*reset\s*$/i, (msg) ->
    script_obj = eval(robot.brain.data["_private"])
    for script of script_obj
      scriptName = /^(script_[a-zA-Z0-9-_]+)\s*$/.exec(script)?[1]
      if scriptName?
        robot.brain.remove(scriptName)
    msg.send "sc reset done"



  robot.respond /\s*sc\s+remove\s+([a-zA-Z-_]+)\s*$/i, (msg) ->
    target = msg.match[1]
    script_obj = eval(robot.brain.data["_private"])
    for script of script_obj
      scriptName = script.match(new RegExp("script_"+target+"\s*$", "i"))?[0]
      if scriptName?
        robot.brain.remove(script)
        msg.send "removed #{script}"



  robot.respond /\s*sc\s+set\s+([a-zA-Z-_]+[0-9]*)\s+(\d+)\s*$/i, (msg) ->
    target = msg.match[1]
    targetCount = parseInt(msg.match[2])
    script_obj = eval(robot.brain.data["_private"])
    for script of script_obj
      scriptName = script.match(new RegExp("(script_"+target+")\s*$", "i"))?[1]
      if scriptName?
        robot.brain.remove(scriptName)
        robot.brain.set(scriptName, targetCount)
        msg.send "set #{targetCount} to #{script}"
