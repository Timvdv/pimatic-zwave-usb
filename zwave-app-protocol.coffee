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
      @zwave.on 'driver failed', () ->
        env.logger.error('failed to start z-wave usb driver')
        @zwave.disconnect()

      @zwave.on "driver ready", (homeid) ->
        console.log('scanning homeid=0x%s...', homeid.toString(16))

      @zwave.on "notification", (nodeid, notif) ->
        switch notif
          when 0 then console.log('node%d: message complete', nodeid)
          when 1 then console.log('node%d: timeout', nodeid)
          when 2 then console.log('node%d: nop', nodeid)
          when 3 then console.log('node%d: node awake', nodeid)
          when 4 then console.log('node%d: node sleep', nodeid)
          when 5 then console.log('node%d: node dead', nodeid)
          when 6 then console.log('node%d: node alive', nodeid)

    pause: (ms=50) ->
      @base.debug "Pausing:", ms, "ms"
      Promise.delay ms

    _triggerResponse: (command, param) ->
      # emulate the regex matcher of telnet transport - should be refactored
      @emit 'response',
        matchedResults: [
          "#{command}#{param}"
          "#{command}",
          "#{param}"
          index:0
          input: "#{command}#{param}"
        ]
        command: command
        param: param
        message: "#{command}#{param}"

    _requestUpdate: (command, param="") =>
      @base.debug "http://#{@host}:#{@port}/goform/#{@_mapZoneToUrlPath command}XmlStatusLite.xml"
      return rest.get "http://#{@host}:#{@port}/goform/#{@_mapZoneToUrlPath command}XmlStatusLite.xml"
      .then (response) =>
        if response.data.length isnt 0
          @base.debug response.data
          parseXmlString response.data
          .then (dom) =>
            prefix = @_mapZoneToCommandPrefix command
            @_triggerResponse "#{prefix}MU", dom.item.Mute[0].value[0].toUpperCase()
            @_triggerResponse "#{prefix}PW", dom.item.Power[0].value[0].toUpperCase()
            volume = parseInt(dom.item.MasterVolume[0].value[0], 10)
            if not isNaN volume
              if dom.item.VolumeDisplay[0].value[0].toUpperCase() is 'ABSOLUTE'
                volume += 80
              @_triggerResponse "#{prefix}MV", volume
            @_triggerResponse "#{prefix}SI", dom.item.InputFuncSelect[0].value[0].toUpperCase()
        else
          throw new Error "Empty result received for status request"
      .finally =>
        delete @scheduledUpdates[@_mapZoneToObjectKey command] if @scheduledUpdates[@_mapZoneToObjectKey command]?

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

    sendRequest: (command, param="", immediate=false) ->
      return new Promise (resolve, reject) =>
        if param isnt '?'
          @base.debug "http://#{@host}:#{@port}/goform/formiPhoneAppDirect.xml?#{command}#{param}"
          promise = rest.get "http://#{@host}:#{@port}/goform/formiPhoneAppDirect.xml?#{command}#{param}"
          .then =>
            @_triggerResponse command, param
        else
          promise = @_scheduleUpdate command, param, immediate

        promise.then =>
          resolve()
        .catch (errorResult) =>
          reject errorResult.error