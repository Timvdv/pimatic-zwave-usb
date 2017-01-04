# coffeelint: disable=max_line_length

module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)

  class ZwavePowerSwitch extends env.devices.PowerSwitch

    constructor: (@config, @plugin, lastState) ->
      @_base = commons.base @, @config.class
      @debug = @plugin.debug || false

      @id = @config.id
      @name = @config.name
      @node = @config.node
      @value_id = null

      @responseHandler = @_createResponseHandler()
      @plugin.protocolHandler.on 'response', @responseHandler
      @_state = lastState?.state?.value or false
      super()

    destroy: () ->
      @_base.cancelUpdate()
      @plugin.protocolHandler.removeListener 'response', @responseHandler
      super()

    _createResponseHandler: () =>
      return (response) =>
        _node = if @node is response.nodeid then response.nodeid else null
        data = response.zwave_response

        if _node? && data.class_id
          @_setState data.value

    changeStateTo: (newState) ->
      return new Promise (resolve, reject) =>
        @plugin.protocolHandler.sendRequest({ node_id: @node, class_id: 37, instance:1, index:0}, newState)
        @_setState newState
        resolve()

    getState: () ->
      return Promise.resolve @_state