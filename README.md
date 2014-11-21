#hubot-rollout-control

hubot-rollout-control is a [Hubot script](https://hubot.github.com/) that allows control of [rollout](https://github.com/FetLife/rollout).

## Installation

Set up [rollout_control](https://github.com/hired/rollout_control) in your Rails app. See [installation instructions](https://github.com/hired/rollout_control#installation).

Add **hubot-rollout-control** to your Hubot (run the following in your Hubot directory):

```
$ npm install --save hubot-rollout-control
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

## Commands

`hubot rollout features` - Prints a list of configured features (`list` is an alias)

`hubot rollout get <feature>` - Prints current configuration for feature (`show` is an alias)

`hubot rollout activate <feature>` - activate feature for all users

`hubot rollout deactivate <feature>` - deactivate feature for all users

`hubot rollout activate_percentage <feature>` <percentage> - activate feature for percentage of users

`hubot rollout activate_group <feature> <group>` - activate feature for group

`hubot rollout deactivate_group <feature> <group>` - deactivate feature for group

`hubot rollout activate_user <feature> <user>` - activate feature for user

`hubot rollout deactivate_user <feature> <user>` - deactivate feature for user

## License

This project is MIT licensed.
