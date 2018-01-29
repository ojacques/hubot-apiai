# Description
#   Talks with api.ai back-end to create smart bots with
#   conversational user experience
#
# Configuration:
#   API_AI_CLIENT_ACCESS_TOKEN
#
# Commands:
#   None
#
# Notes:
#   This script responds to everything and get a dialog
#   going with api.ai. Once the intent is fully resolved,
#   it uses robot.emit to trigger additional logic to handle the intent.
#   It essentially act as an intelligent router for your scripts.
#   NOTE: this script may have to be the only one listening to
#         chat conversations or you may get conflicts / double answers
#
# Author:
#   Olivier Jacques

apiai = require('apiai')
util = require('util')

ai = apiai(process.env.API_AI_CLIENT_ACCESS_TOKEN)

module.exports = (robot) ->
  robot.respond /(.*)/i, (msg) ->
    query = msg.match[1]
    askAI(query, msg, getSession(msg))

  getSession = (msg) ->
    # Get session context from a thread, or create a user specific session
    if robot.adapterName == 'flowdock'
      return msg.message.metadata.thread_id
    else if robot.adapterName == 'slack'
      #Using the user id as the sessionId allows chat continuity to the bot from either channel mentions or direct messages. If you want direct messages and channel mentions to the bot handled differently, you can append the channel/room id. Append this in the returned session this: "msg.message.rawMessage.channel.id"
      return msg.message.user.id
    else
      # We can't rely on threading mechanism: fallback to one session per user
      session_id = "session-" + msg.message.user["id"];
      return session_id

  askAI = (query, msg, session) ->
    # Process conversation with AI back-end
    unless process.env.API_AI_CLIENT_ACCESS_TOKEN?
      msg.send "I need a token to be smart :grin:"
      robot.logger.error "API_AI_CLIENT_ACCESS_TOKEN not set"
      return

    robot.logger.debug("Calling API.AI with '#{query}' and session #{session}")
    request = ai.textRequest(query, {sessionId: session})
    request.on('response', (response) ->
      robot.logger.debug("From API.AI: " + util.inspect(response))
      if (response.result.actionIncomplete is true)
        # Still refining...
        msg.send(response.result.fulfillment.speech)
      else if (response.result.metadata? &&
               response.result.metadata.intentId? &&
               response.result.action isnt "input.unknown")

        # API.AI has determined the intent
        msg.send(response.result.fulfillment.speech)
        robot.logger.info("Emitting robot action: " +
                    response.result.metadata.intentName + ", " +
                    util.inspect(response.result.parameters))
        # Emit event with message context and parameters
        robot.emit response.result.metadata.intentName, msg, response.result.parameters
      else
        # Default or small talk
        if (response.result.fulfillment.speech?)
          msg.send(response.result.fulfillment.speech)
    )
    request.on('error', (error) ->
      robot.logger.error(error)
    )
    request.end()
