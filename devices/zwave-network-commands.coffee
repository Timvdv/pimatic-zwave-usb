# coffeelint: disable=max_line_length

module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)

  # Device class representing the power switch of the Denon AVR
  class ZwaveNetworkCommands extends env.devices.ButtonsDevice

    # Create a new DenonAvrInputSelector device
    # @param [Object] config    device configuration
    # @param [DenonAvrPlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @_base = commons.base @, @config.class
      @id = @config.id
      @name = @config.name

      @debug = @plugin.debug || false
      for b in @config.buttons
        b.text = b.id unless b.text?

      super(@config)

    destroy: () ->
      @_base.cancelUpdate()
      @plugin.protocolHandler.removeListener 'response', @responseHandler
      super()

    _createResponseHandler: () ->
      return (response) =>
        @_base.debug "Response", response.matchedResults
        if response.command is @zoneCmd and
            response.param isnt @_lastPressedButton and response.param isnt 'OFF'
          @_lastPressedButton = response.param
          @emit 'button', response.param

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          return @plugin.protocolHandler.healNetwork();

      throw new Error("No button with the id #{buttonId} found")