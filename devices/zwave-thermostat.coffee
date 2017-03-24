# coffeelint: disable=max_line_length

module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  
  class ZwaveThermostat extends env.devices.HeatingThermostat
    constructor: (@config, @plugin, lastState) ->
      @_base = commons.base @, @config.class
      @debug = @plugin.debug || false

      @id = @config.id
      @name = @config.name
      @node = @config.node
      @value_id = null

      @_mode = "auto"
      @_setSynced(false)

      @responseHandler = @_createResponseHandler()
      @plugin.protocolHandler.on 'response', @responseHandler

      @_temperatureSetpoint = lastState?.temperatureSetpoint?.value or null
      @_battery = lastState?.battery?.value or "--"
      @_valve = lastState?.valve?.value or null
      @_lastSendTime = 0
      @syncTimeoutTime = @config.syncTimeout * 1000 * 60

      if @syncTimeoutTime > 0
        @timestamp = (new Date()).getTime()
        @setTimestampInterval()

      super()

    timer: ->
      current_time = (new Date()).getTime()
      time_since_last_sync =  current_time - @timestamp
      if time_since_last_sync > @syncTimeoutTime
        @_setSynced(false)

    setTimestampInterval: ->
      cb = @timer.bind @
      setInterval cb, @syncTimeoutTime

    _createResponseHandler: () ->
      return (response) =>
        _node = if @node is response.nodeid then response.nodeid else null
        data = response.zwave_response

        if _node?
          #Update the temperture
          @value_id = data.value_id

          @_base.debug "Response", response

          if data.class_id is 67
            @_base.debug "update temperture", data.value
            @_setSetpoint(parseInt(data.value))
            @_setValve(parseInt(data.value) / 28 * 100) #28 == 100%
            @_setSynced(true)
            @timestamp = (new Date()).getTime()

          if data.class_id is 128
            @_base.debug "Update battery", data.value
            battery_value = if parseInt(data.value) < 5 then 'LOW' else 'OK'
            @_setBattery(battery_value)

    _callbackHandler: () ->
      return (response) =>
        #@TODO: ???
        @_base.debug 'what is this.. when does it happen?? (_callbackHandler in ZwaveThermostat)'

    destroy: () ->
      @_base.cancelUpdate()
      @plugin.protocolHandler.removeListener 'response', @responseHandler
      super()

    changeTemperatureTo: (temperatureSetpoint) =>
      return new Promise (resolve, reject) =>
        if @_temperatureSetpoint is temperatureSetpoint then return Promise.resolve()

        if(@value_id)
          @plugin.protocolHandler.sendRequest({ value_id: @value_id, node_id: @node, class_id: 67, instance:1, index:1}, parseFloat(temperatureSetpoint).toFixed(2), "thermostat")
        else
          @_base.info "Please wake up ", @name, " device has no value_id yet"

        @_setSetpoint(parseInt(temperatureSetpoint));
        resolve()

    getTemperature: -> Promise.resolve(@_temperatureSetpoint)
