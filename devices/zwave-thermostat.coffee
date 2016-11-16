# coffeelint: disable=max_line_length

module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)

  # Todo.. Implement last state
  #return @_lastAction
  #valueId:{"value_id":"4-67-1-1","node_id":4,"class_id":67,"type":"decimal","genre":"user","instance":1,"index":1,"label":"Heating 1","units":"C","help":"","read_only":false,"write_only":false,"is_polled":false,"min":0,"max":0,"value":"18.00"}

  class ZwaveThermostat extends env.devices.HeatingThermostat
    constructor: (@config, @plugin, lastState) ->
      @_base = commons.base @, @config.class
      @debug = @plugin.debug || false

      @id = @config.id
      @name = @config.name
      
      @responseHandler = @_createResponseHandler()
      @plugin.protocolHandler.on 'value changed', @responseHandler
      
      @_temperatureSetpoint = lastState?.temperatureSetpoint?.value
      @_battery = lastState?.battery?.value or "--"
      @_lastSendTime = 0

      super()

      _createResponseHandler: () ->
        return (nodeid, commandclass, valueId) =>
          console.log("resHandler:", nodeid)
          #this is where we check if values in the network are
          #manually changed, then we update it in pimatic
          #if(@debug)
          env.logger.info("(custom) updated: " + nodeid)
          env.logger.info("(custom) command class: " + commandclass)
          env.logger.info("(custom) valueId:" + JSON.stringify(valueId))

          #Set nodeid if it's the same one as you added
          _node = @config.node == nodeid ? nodeid : null
          data = valueId

          if _node?
            #Update the temperture
            if data.value is not @_temperatureSetpoint and commandclass == 67
              @_setSetpoint(data.value)

            #Update the battery
            if data.value is not @_battery and commandclass == 128
              @_setBattery(data.battery)

      _callbackHandler: () ->
        return (response) =>
          console.log('wut is deze?? (_callbackHandler in ZwaveThermostat)')

      destroy: () ->
        @_base.cancelUpdate()

        #Does this remove all 'value changed' events? Because I also use it with other devices
        @plugin.protocolHandler.removeListener 'value changed', @responseHandler
        super()

      changeTemperatureTo: (temperatureSetpoint) ->
        if @_temperatureSetpoint is temperatureSetpoint then return Promise.resolve()

        #make temperature a whole number
        temp = Math.round(value*10)

        #create 2 byte buffer of the value
        tempByte1 = Math.floor(temp/255)
        tempByte2 = Math.round(temp-(255*tempByte1))
        temp = new Buffer([tempByte1, tempByte2])

        #tell protocol to set value..
        #@plugin.protocolHandler.setValue({ node_id:_node, class_id: 67, instance:1, index:0}, temp)

        return @_setSetpoint(temperatureSetpoint)

      getTemperature: -> Promise.resolve(@_temperatureSetpoint)
