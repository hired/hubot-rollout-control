_     = require 'lodash'
chai  = require 'chai'
sinon = require 'sinon'

chai.use require 'sinon-chai'
chai.use require 'chai-as-promised'

Robot = require 'hubot/src/robot'
global.mockBot = ->
  new Promise (done, fail) ->
    _.tap (new Robot null, 'mock-adapter', false, 'bot'), (robot) ->
      # A user to be for the tests.  Create more if needed, with unique IDs.
      # Stub anything else on `robot.brain` in a before block
      testUser = robot.brain.userForId "1",
        name: 'testy'
        room: '#test'

      # When the bot is connected, resolve the promise with it
      robot.adapter.on 'connected', -> done {robot: robot, testUser: testUser}

      receive = _.bind robot.receive, robot
      robot.receive = (msg) ->
        if _.isString msg
          receive new TextMessage testUser, msg
        else
          receive msg

      robot.routes = {}
      robot.router =
        get: (route, callback)=>
          robot.routes[route] = { get: callback }
        post: (route, callback)->
          robot.routes[route] = { post: callback }
        put: (route, callback)=>
          robot.routes[route] = { put: callback }
        delete: (route, callback)=>
          robot.routes[route] = { delete: callback }

      shutdown = _.bind robot.shutdown, robot
      robot.shutdown = ->
        # Hubot adds this listener and does not remove it on shutdown
        process.removeAllListeners 'uncaughtException'
        shutdown()

      # 'start' the bot
      robot.run()

chai.use ({Assertion}, utils) ->
  _.each ['send', 'reply'], (method) ->
    Assertion.addMethod method, (val) ->
      bot  = utils.flag @, 'object'
      room = utils.flag @, 'room'
      promise = new Promise (done, fail) =>
        listener = (env, strings) =>
          bot.adapter.removeListener method, listener
          if room && room != env.room
            fail new Error "expected room to be #{room}, was #{env.room}"

          done if _.isArray val then strings else _.first strings

        bot.adapter.on method, listener

      if _.isEmpty(val) || val == '*'
        _.tap (new Assertion(promise).to.eventually.exist), (assertion) ->
          utils.flag assertion, 'object', bot

      else if _.isString(val) && val.match(/\*/)
        regex = new RegExp(val.replace(/\*/, '.*'))
        _.tap (new Assertion(promise).to.eventually.match regex), (assertion) ->
          utils.flag assertion, 'object', bot

      else
        _.tap (new Assertion(promise).to.eventually.equal val), (assertion) ->
          utils.flag assertion, 'object', bot

  Assertion.addMethod 'careAbout', (msg) ->
    bot = utils.flag @, 'object'
    this.assert(_.any bot.listeners, (lsnr)-> msg.match(lsnr.regex))

  Assertion.addChainableMethod 'in'
  Assertion.addChainableMethod 'room', (val) -> utils.flag @, 'room', val

global.expect  = chai.expect
global.sinon   = sinon
global.RSVP    = require 'rsvp'
global.Promise = RSVP.Promise
global.moment  = require 'moment'
global.nock    = require 'nock'
global._       = _
global.TextMessage = (require 'hubot/src/message').TextMessage

nock.disableNetConnect()
