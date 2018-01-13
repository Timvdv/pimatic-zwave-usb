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

        if _node? && data.class_id
          @_setState data.value
    
    changeDimlevelTo: (newLevel) ->
      return new Promise (resolve, reject) =>
        @plugin.protocolHandler.sendRequest({ node_id: @node, class_id: 38, instance:1, index:0}, newLevel)
        @_setState newState
        resolve()

    getState: () ->
      return Promise.resolve @_state
    
    getDimlevel: () ->
      return Promise.resolve @_dimlevel
