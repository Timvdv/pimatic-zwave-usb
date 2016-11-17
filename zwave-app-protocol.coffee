# HttpAppProtocol class
# coffeelint: disable=max_line_length

module.exports = (env) ->
  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)

  # Include open-zwave lib
  ZWave = require 'openzwave-shared'

  class ZwaveAppProtocol extends require('events').EventEmitter
    constructor: (@config) ->
      @scheduledUpdates = {}
      @usb = @config.usb
      @debug = @config.debug || false
      @base = commons.base @, 'ZwaveAppProtocol'
      @on "newListener", =>
        @base.debug "Status response event listeners: #{1 + @listenerCount 'response'}"

      @zwave = new ZWave({
        Logging: false, #logs to file
        ConsoleOutput: false #logs to console
      })

      @zwave.connect(@usb)

      #stop zwave and return an error if the driver fails
      @zwave.on 'driver failed', () =>
        @base.error 'failed to start z-wave usb driver'
        @zwave.disconnect()

      @zwave.on "driver ready", (homeid) =>
        @base.debug 'scanning homeid=0x', homeid.toString(16)

      @zwave.on "notification", (nodeid, notif) =>
        switch notif
          when 0 then @base.debug 'node', nodeid, ': message complete'
          when 1 then @base.debug 'node', nodeid, ': timeout'
          #when 2 then @base.debug 'node', nodeid, ': nop'
          when 3 then @base.debug 'node', nodeid, ': node awake'
          when 4 then @base.debug 'node', nodeid, ': node sleep'
          when 5 then @base.debug 'node', nodeid, ': node dead'
          when 6 then @base.debug 'node', nodeid, ': node alive'

      @zwave.on "value changed", (nodeid, commandclass, valueId) =>
        @base.debug "custom: value changed:", nodeid, commandclass, valueId
        
        if valueId
          @_triggerResponse valueId, nodeid

    _triggerResponse: (zwave_response, nodeid) ->
      @emit 'response',
        nodeid: nodeid
        zwave_response: zwave_response

    pause: (ms=50) =>
      @base.debug "Pausing:", ms, "ms"
      Promise.delay ms

    _requestUpdate: (command, param="") =>
      @base.debug "Send command: #{command} to #{@node}"

      return new Promise (resolve, reject) =>
        @base.debug("request update!!")
        resolve()

    #@TODO: remove this? I probably don't need it
    _scheduleUpdate: (command, param="", immediate) ->
      timeout=1500
      if not @scheduledUpdates[@_mapZoneToObjectKey command]?
        @base.debug "Scheduling update for zone #{@_mapZoneToObjectKey command}"
        @scheduledUpdates[@_mapZoneToObjectKey command] = true
        timeout=0 if immediate
      else
        @base.debug "Re-scheduling update for zone #{@_mapZoneToObjectKey command}"
        @base.cancelUpdate()
      @base.scheduleUpdate @_requestUpdate, timeout, command, param
      return Promise.resolve()

    sendRequest: (command, temp) =>
      return new Promise (resolve, reject) =>
        @zwave.setValue(command, temp)
        resolve()