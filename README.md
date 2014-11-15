#hubot-rollout-control

hubot-rollout-control is a [Hubot script](https://hubot.github.com/) that allows control of [rollout](https://github.com/FetLife/rollout).

## Installation

Set up [rollout_control](https://github.com/hired/rollout_control) in your Rails app. See [installation instructions](https://github.com/hired/rollout_control#installation).

Add **hubot-rollout-control** to dependencies in Hubot's `package.json` file:

```json
"dependencies": {
  "hubot": ">= 2.6.0",
  "hubot-scripts": ">= 2.5.0",
  "hubot-rollout-control": ">= 0.0.2"
}
```

Add **hubot-rollout-control** to Hubot's `external-scripts.json`:

```json
["hubot-rollout-control"]
```

* Set `HUBOT_ROLLOUT_CONTROL_URL` to point to where you mounted rollout_control. For example: `http://my-super-app.com/rollout`.
* Set `HUBOT_ROLLOUT_CONTROL_USERNAME` to your configured rollout_control basic auth username.
* Set `HUBOT_ROLLOUT_CONTROL_PASSWORD` to your configured rollout_control basic auth password.

If everything is set up correctly, you can now control rollout with Hubot.

=====

**aaron**<br />
hubot rollout features<br />
**hubot**<br />
experimental_feature (0%)<br />
kittens (50%), groups: [ cat_lovers ], users: [ 14 ]<br />
**aaron**<br />
hubot rollout activate experimental_feature<br />
**hubot**<br />
experimental_feature has been activated<br />
**aaron**<br />
hubot rollout activate_user kittens 75<br />
**hubot**<br />
kittens has been activated for user with id 75<br />
**aaron**<br />
hubot rollout features<br />
**hubot**<br />
experimental_feature (100%)<br />
kittens (50%), groups: [ cat_lovers ], users: [ 14, 75 ]<br />

=====

## License

This project is MIT licensed.