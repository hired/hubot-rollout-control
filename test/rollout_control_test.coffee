hubot_rollout_control = require '../src/hubot-rollout-control'

describe 'hubot-rollout-control', ->
  bot = user = undefined
  rcUrl = 'http://hired.com'
  beforeEach (done) ->
    process.env.HUBOT_ROLLOUT_CONTROL_URL = "#{rcUrl}/rollout"
    process.env.HUBOT_ROLLOUT_CONTROL_USERNAME = ''
    process.env.HUBOT_ROLLOUT_CONTROL_PASSWORD = ''

    mockBot().then ({robot, testUser}) ->
      bot = robot
      user = testUser
      hubot_rollout_control robot
      done()
    afterEach -> bot.shutdown()

  describe 'list', ->

    it 'lists features when they exist', (done) ->
      botPromise = expect(bot).to.send(
        """
        kittens (100%)
        burritos (50%), groups: [ hired ], users: [ 55, 62 ]
        """
      )
      listNock = nock(rcUrl).get('/rollout/features').reply(200,
        [
          {"percentage":100,"groups":[],"users":[],"name":"kittens"},
          {"percentage":50,"groups":["hired"],"users":["55", "62"],"name":"burritos"}
        ]
      )
      bot.receive 'bot rollout list'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

    it 'shows a helpful message when there are no features', (done) ->
      botPromise = expect(bot).to.send('(no features are configured)')
      listNock = nock(rcUrl).get('/rollout/features').reply(200, [])
      bot.receive 'bot rollout list'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'get', ->

    it 'shows basic info for a feature', (done) ->
      botPromise = expect(bot).to.send('jetpack (75%)')
      listNock = nock(rcUrl).get('/rollout/features/jetpack').reply(200,
        {"percentage":75,"groups":[],"users":[],"name":"jetpack"}
      )
      bot.receive 'bot rollout get jetpack'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

    it 'shows extended info for a feature', (done) ->
      botPromise = expect(bot).to.send('jetpack (75%), groups: [ women, men, cats ], users: [ 77 ]')
      listNock = nock(rcUrl).get('/rollout/features/jetpack').reply(200,
        {"percentage":75,"groups":["women", "men", "cats"],"users":["77"],"name":"jetpack"}
      )
      bot.receive 'bot rollout get jetpack'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'activate', ->

    it 'sets a given feature to 100%', (done) ->
      botPromise = expect(bot).to.send('hot_dog_cannon has been activated')
      listNock = nock(rcUrl).patch(
        '/rollout/features/hot_dog_cannon',
        { percentage: 100 }
      ).reply(204)
      bot.receive 'bot rollout activate hot_dog_cannon'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'deactivate', ->

    it 'sets a given feature to 0%', (done) ->
      botPromise = expect(bot).to.send('hot_dog_cannon has been deactivated')
      listNock = nock(rcUrl).patch(
        '/rollout/features/hot_dog_cannon',
        { percentage: 0 }
      ).reply(204)
      bot.receive 'bot rollout deactivate hot_dog_cannon'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'activate_percentage', ->

    it 'sets a given feature to the given percentage', (done) ->
      botPromise = expect(bot).to.send('hot_dog_cannon has been activated for 73% of users')
      listNock = nock(rcUrl).patch(
        '/rollout/features/hot_dog_cannon',
        { percentage: 73 }
      ).reply(204)
      bot.receive 'bot rollout activate_percentage hot_dog_cannon 73%'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

    it 'does not require a "%" in the command', (done) ->
      botPromise = expect(bot).to.send('hot_dog_cannon has been activated for 73% of users')
      listNock = nock(rcUrl).patch(
        '/rollout/features/hot_dog_cannon',
        { percentage: 73 }
      ).reply(204)
      bot.receive 'bot rollout activate_percentage hot_dog_cannon 73'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

    it 'shows a helpful message when percentage is below 0%', (done) ->
      _.tap expect(bot).to.send(
        'Please specify a percentage of 0% or greater'
      ), ->
        bot.receive 'bot rollout activate_percentage hot_dog_cannon -5%'
      done()

    it 'shows a helpful message when percentage is above 100%', (done) ->
      _.tap expect(bot).to.send(
        "I know you're giving it 110%, but please specify a percentage no greater than 100%"
      ), ->
        bot.receive 'bot rollout activate_percentage hot_dog_cannon 125%'
      done()

    it 'shows a helpful message when percentage is not a number', (done) ->
      _.tap expect(bot).to.send(
        'Percentage must be a number'
      ), ->
        bot.receive 'bot rollout activate_percentage hot_dog_cannon wat'
      done()

  describe 'activate_group', ->

    it 'adds a group to the given feature', (done) ->
      botPromise = expect(bot).to.send('sportsball has been activated for sports_fans')
      listNock = nock(rcUrl).post(
        '/rollout/features/sportsball/groups',
        { group: 'sports_fans' }
      ).reply(204)
      bot.receive 'bot rollout activate_group sportsball sports_fans'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'deactivate_group', ->

    it 'removes a group from the given feature', (done) ->
      botPromise = expect(bot).to.send('sportsball has been deactivated for sports_fans')
      listNock = nock(rcUrl).delete(
        '/rollout/features/sportsball/groups/sports_fans'
      ).reply(204)
      bot.receive 'bot rollout deactivate_group sportsball sports_fans'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'activate_user', ->

    it 'adds a user to the given feature', (done) ->
      botPromise = expect(bot).to.send('keytar has been activated for user with id 55')
      listNock = nock(rcUrl).post(
        '/rollout/features/keytar/users',
        { user_id: 55 }
      ).reply(204)
      bot.receive 'bot rollout activate_user keytar 55'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'deactivate_user', ->

    it 'removes a user from the given feature', (done) ->
      botPromise = expect(bot).to.send('keytar has been deactivated for user with id 55')
      listNock = nock(rcUrl).delete(
        '/rollout/features/keytar/users/55'
      ).reply(204)
      bot.receive 'bot rollout deactivate_user keytar 55'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

  describe 'configuration', ->

    it 'shows a helpful message when URL is not configured', () ->
      process.env.HUBOT_ROLLOUT_CONTROL_URL = ''
      _.tap expect(bot).to.send(
        'HUBOT_ROLLOUT_CONTROL_URL environment variable must be set with the rollout_control URL'
      ), ->
        bot.receive 'bot rollout list'

    it 'adds basic authentication header when configured', (done) ->
      process.env.HUBOT_ROLLOUT_CONTROL_USERNAME = 'hired'
      process.env.HUBOT_ROLLOUT_CONTROL_PASSWORD = 'lolwut'
      botPromise = expect(bot).to.send('(no features are configured)')
      auth = "Basic #{new Buffer("#{process.env.HUBOT_ROLLOUT_CONTROL_USERNAME}:#{process.env.HUBOT_ROLLOUT_CONTROL_PASSWORD}").toString('base64')}"
      listNock = nock(rcUrl).get('/rollout/features').matchHeader('Authorization', (val) -> val == auth).reply(200, [])
      bot.receive 'bot rollout list'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

    it 'lets you know credentials are missing on a 401', (done) ->
      botPromise = expect(bot).to.send('Not authorized to use rollout_control API: set HUBOT_ROLLOUT_CONTROL_USERNAME and HUBOT_ROLLOUT_CONTROL_PASSWORD environment variables')
      listNock = nock(rcUrl).get('/rollout/features').reply(401)
      bot.receive 'bot rollout list'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done

    it 'lets you know credentials are wrong on a 401', (done) ->
      process.env.HUBOT_ROLLOUT_CONTROL_USERNAME = 'hired'
      process.env.HUBOT_ROLLOUT_CONTROL_PASSWORD = 'lolwut'
      botPromise = expect(bot).to.send('Not authorized to use rollout_control API: HUBOT_ROLLOUT_CONTROL_USERNAME and/or HUBOT_ROLLOUT_CONTROL_PASSWORD are incorrect')
      listNock = nock(rcUrl).get('/rollout/features').reply(401)
      bot.receive 'bot rollout list'
      botPromise.then ->
        listNock.done()
        done()
      .then null, done
