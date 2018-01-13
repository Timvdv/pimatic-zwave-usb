# coffeelint: disable=max_line_length

module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)

  class ZwavePowerSwitch extends env.devices.DimmerActuator

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
      @_dimlevel = lastState?.dimlevel?.value or 0
      super()

    destroy: () ->
      @_base.cancelUpdate()
      @plugin.protocolHandler.removeListener 'response', @responseHandler
      super()

    _createResponseHandler: () =>
      return (response) =>
        _node = if @node is response.nodeid then response.nodeid else null
        data = response.zwave_response

        if _node? && data.class_id && data.class_id==38 && data.instance == 1
          #env.logger.info("data", data)
          @_setDimlevel data.value

    changeDimlevelTo: (newLevel) ->
      return new Promise (resolve, reject) =>
        @plugin.protocolHandler.sendRequest({ node_id: @node, class_id: 38, instance:1, index:0}, newLevel)
        @_setDimlevel newLevel
        resolve()

    getDimlevel: () ->
      return Promise.resolve @_dimlevel
