# coffeelint: disable=max_line_length

module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)

  class ZwavePowerSwitchNeo extends env.devices.PowerSwitch
    
    constructor: (@config, @plugin, lastState) ->
      @_base = commons.base @, @config.class
      @debug = @plugin.debug || false

      @id = @config.id
      @name = @config.name
      @node = @config.node
      @value_id = null
      @update = (new Date()).getTime()
      @responseHandler = @_createResponseHandler()
      @plugin.protocolHandler.on 'response', @responseHandler
      @_state = lastState?.state?.value or false
      @_current = lastState?.current?.value or null
      @_voltage = lastState?.voltage?.value or null

      @updateTime = @config.updateTimeout * 1000

      if @updateTime > 0
        @timestamp = (new Date()).getTime()
#        @setUpdateInterval()


      super()

#    timer: ->
#     current_time = (new Date()).getTime()
#      time_since_last_update =  current_time - @timestamp
#      if time_since_last_update > @updateTime
#        @_base.debug "Timestamp", @timestamp, "time since last update", time_since_last_update
#        @_setSynced(false)

#    setUpdateInterval: ->
#      cb = @timer.bind @
#      setInterval cb, @updateTime

    attributes:
      state:
        description: "state of the contact"
        type: "boolean"
        labels: ['on', 'off']
#      synced:
#        description: "Pimatic and thermostat in sync"
#        type: "boolean"
#      battery:
#        description: "Battery status"
#        type: "string"
#        enum: ["ok", "low"]
      current:
        label: "Current"
        description: "The current measured"
        type: "number"
        discrete: false
        unit: "A"
       voltage:
        label: "Voltage"
        description: "The voltage measured"
        type: "number"
        unit: "V"
#        unit: "°C"
       power:
        label: "Power"
        description: "The power measured"
        type: "number"
        unit: "W"
       energy:
        label: "Energy"
        description: "The Energy consumed"
        type: "number"
        unit: "kWh"

    
#    getState: () -> Promise.resolve(@_contact)
    getCurrent: () -> Promise.resolve(@_current)
#    getBattery: () -> Promise.resolve(@_battery)
#    getSynced: () -> Promise.resolve(@_synced)
    getVoltage: () -> Promise.resolve(@_voltage)
    getPower: () -> Promise.resolve(@_power)
    getEnergy: () -> Promise.resolve(@_energy)


    _setCurrent: (current) ->
#      update  = (new Date()).getTime()
      current_time = (new Date()).getTime()
      time_since_last_update =  current_time - @update
      @_base.debug "--update", @update, "time since last update", time_since_last_update, "Updatetime:", @updateTime
      if time_since_last_update > @updateTime
       @_base.debug "update", @update, "time since last update", time_since_last_update, "Updatetime:", @updateTime
       @update  = (new Date()).getTime()
       time_since_last_update = 0 
       @_current = current
       @emit "current", @_current

      if current is @_current then return
      @_current = current
      @emit "current", @_current

    _setVoltage: (voltage) ->
      if voltage is @_voltage then return
      @_voltage = voltage
      @emit "voltage", @_voltage

    _setPower: (power) ->
      if power is @_power then return
      @_power = power
      @emit "power", @_power

    _setEnergy: (energy) ->
      if energy is @_energy then return
      @_energy = energy
      @emit "energy", @_energy


    destroy: () ->
      @_base.cancelUpdate()
      @plugin.protocolHandler.removeListener 'response', @responseHandler
      super()

    _createResponseHandler: () =>
      return (response) =>
        _node = if @node is response.nodeid then response.nodeid else null
        data = response.zwave_response
#debugging info
        @_base.debug "data: ", data
        @_base.debug "class_id, instance, index: ", data.class_id, data.instance, data.index
#
        if data.class_id is 50 && data.index is 20 && data.node_id is @node
         @_base.debug "class 50, index 20: (current) ", parseFloat(data.value)
         current = parseFloat(data.value)
         @_setCurrent(current)


        if data.class_id is 50 && data.index is 16 && data.node_id is @node
         @_base.debug "voltage: ", parseFloat(data.value)
         voltage = parseFloat(data.value)
         @_setVoltage(voltage)

#power is index 8
        if data.class_id is 50 && data.index is 8 && data.node_id is @node
         @_base.debug "power: ", parseFloat(data.value)
         power = parseFloat(data.value)
         @_setPower(power)

#energy is index 0
        if data.class_id is 50 && data.index is 0 && data.node_id is @node
         @_base.debug "energy: ", parseFloat(data.value)
         energy = parseFloat(data.value)
         @_setEnergy(energy)


        if data.class_id is 37 && data.index is 0 && data.node_id is @node
         @_base.debug "switch: ", data.value
         @_setState data.value

    changeStateTo: (newState) ->
      return new Promise (resolve, reject) =>
        @plugin.protocolHandler.sendRequest({ node_id: @node, class_id: 37, instance:1, index:0}, newState)
        @_setState newState
        resolve()

    getState: () ->
      return Promise.resolve @_state


