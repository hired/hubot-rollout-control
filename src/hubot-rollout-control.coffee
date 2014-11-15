# Description:
#   Client for rollout_control API - used to control rollout in a Rails app
#
# Dependencies:
#   rollout-control-client
#
# Configuration:
#   HUBOT_ROLLOUT_CONTROL_URL
#   HUBOT_ROLLOUT_CONTROL_USERNAME
#   HUBOT_ROLLOUT_CONTROL_PASSWORD
#
# Commands:
#   hubot rollout list - Prints a list of configured features
#   hubot rollout get <feature> - Prints current configuration for feature
#   hubot rollout activate <feature> - activate feature for all users
#   hubot rollout deactivate <feature> - deactivate feature for all users
#   hubot rollout activate_percentage <feature> <percentage> - activate feature for percentage of users
#   hubot rollout activate_group <feature> <group> - activate feature for group
#   hubot rollout deactivate_group <feature> <group> - deactivate feature for group
#   hubot rollout activate_user <feature> <user> - activate feature for user
#   hubot rollout deactivate_user <feature> <user> - deactivate feature for user
{Promise} = require 'rsvp'
RolloutControl = require 'rollout-control-client'

formatFeature = ({name, percentage, groups, users}) ->
  pieces = ["#{name} (#{percentage}%)"]
  pieces.push "groups: [ #{groups.join(', ')} ]" if groups.length > 0
  pieces.push "users: [ #{users.join(', ')} ]" if users.length > 0
  pieces.join(', ')

errorMessage = (error) ->
  if error.unauthorized
    message = if process.env.HUBOT_ROLLOUT_CONTROL_USERNAME
      'HUBOT_ROLLOUT_CONTROL_USERNAME and/or HUBOT_ROLLOUT_CONTROL_PASSWORD are incorrect'
    else
      'set HUBOT_ROLLOUT_CONTROL_USERNAME and HUBOT_ROLLOUT_CONTROL_PASSWORD environment variables'
    return "Not authorized to use rollout_control API: #{message}"
  else
    "Error with rollout_control service: #{error.message}"

module.exports = (robot) ->

  command = (pattern, body) ->
    robot.respond pattern, (msg) ->
      unless process.env.HUBOT_ROLLOUT_CONTROL_URL
        return msg.send 'HUBOT_ROLLOUT_CONTROL_URL environment variable must be set with the rollout_control URL'
      rollout = new RolloutControl.Client(
        process.env.HUBOT_ROLLOUT_CONTROL_URL,
        process.env.HUBOT_ROLLOUT_CONTROL_USERNAME,
        process.env.HUBOT_ROLLOUT_CONTROL_PASSWORD
      )
      body(msg, rollout).then null, (error) -> msg.send errorMessage(error)

  command /rollout list/i, (msg, rollout) ->
    rollout.list().then (features) ->
      if features.length == 0
        msg.send '(no features are configured)'
      else
        msg.send (formatFeature(feature) for feature in features).join("\n")

  command /rollout (get|show) (\S+)/i, (msg, rollout) ->
    rollout.get(msg.match[2]).then (feature) ->
      msg.send formatFeature(feature)

  command /rollout activate (\S+)\s*?$/i, (msg, rollout) ->
    featureName = msg.match[1]
    rollout.activate(featureName).then ->
      msg.send "#{featureName} has been activated"

  command /rollout deactivate (\S+)\s*?$/i, (msg, rollout) ->
    featureName = msg.match[1]
    rollout.deactivate(featureName).then ->
      msg.send "#{featureName} has been deactivated"

  command /rollout activate(_| )percentage (\S+) (\S+)/i, (msg, rollout) ->
    [featureName, percentage] = [msg.match[2], msg.match[3].replace(/%$/, '')]
    percentageNum = parseInt(percentage, 10)
    if isNaN(percentageNum) then msg.send 'Percentage must be a number'; return Promise.resolve()
    else if percentageNum < 0 then msg.send "Please specify a percentage of 0% or greater"; return Promise.resolve()
    else if percentageNum > 100 then msg.send "I know you're giving it 110%, but please specify a percentage no greater than 100%"; return Promise.resolve()

    rollout.activatePercentage(featureName, percentage).then ->
      msg.send "#{featureName} has been activated for #{percentage}% of users"

  command /rollout activate(_| )group (\S+) (\S+)/i, (msg, rollout) ->
    [featureName, groupName] = [msg.match[2], msg.match[3]]
    rollout.activateGroup(featureName, groupName).then ->
      msg.send "#{featureName} has been activated for #{groupName}"

  command /rollout deactivate(_| )group (\S+) (\S+)/i, (msg, rollout) ->
    [featureName, groupName] = [msg.match[2], msg.match[3]]
    rollout.deactivateGroup(featureName, groupName).then ->
      msg.send "#{featureName} has been deactivated for #{groupName}"

  command /rollout activate(_| )user (\S+) (\S+)/i, (msg, rollout) ->
    [featureName, userId] = [msg.match[2], msg.match[3]]
    rollout.activateUser(featureName, userId).then ->
      msg.send "#{featureName} has been activated for user with id #{userId}"

  command /rollout deactivate(_| )user (\S+) (\S+)/i, (msg, rollout) ->
    [featureName, userId] = [msg.match[2], msg.match[3]]
    rollout.deactivateUser(featureName, userId).then ->
      msg.send "#{featureName} has been deactivated for user with id #{userId}"
