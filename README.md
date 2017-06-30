# Add smartness to hubot with API.AI

A hubot script that adds  conversational user experience with [api.ai](https://api.ai)
as back-end.

When you talk to Hubot, this script sends the text to api.ai, which 
in turns handles the dialog and detects intents and parameters.
Finally, the script [emits an event (robot.emit)](https://github.com/hubotio/hubot/blob/master/docs/scripting.md#events)
so that it can be consumed by other scripts.

![example](img/hubot-api-ai.gif)

See [`src/apiai.coffee`](https://raw.github.hpe.com/olivier-jacques/hubot-screenshot/master/src/screenshot.coffee) 
for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-apiai --save`

Then add **hubot-apiai** to your `external-scripts.json`:

```json
[
  "hubot-apiai"
]
```

## Configuration variable

`API_AI_CLIENT_ACCESS_TOKEN`: API AI client access token which you get from https://console.api.ai/api-client/ 

## Create listener scripts

hubot-apiai will [emit events](https://github.com/hubotio/hubot/blob/master/docs/scripting.md#events)
which correspond to intents that you describe in API.AI.

Let's say that you have an intent called `help-me` in API.AI. You can create
an hubot script which will act on `help-me` intents:

```
module.exports = (robot) ->
  robot.on "help-me", (msg, params) ->
    # Your code here
```

The parameters from the intent are passed as part of Hubot's event.

## NPM Module

https://www.npmjs.com/package/hubot-apiai

## TODO

- Add tests
