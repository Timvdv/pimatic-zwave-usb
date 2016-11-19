# ZWave plugin
# By Tim van de Vathorst
# coffeelint: disable=max_line_length

module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  commons = require('pimatic-plugin-commons')(env)
  ZwaveAppProtocol = require('./zwave-app-protocol')(env)

  deviceConfigTemplates = [
    {
      "name": "ZWave-usb Thermostat",
      "class": "ZwaveThermostat"
    },
    {
      "name": "ZWave-usb Power Switch",
      "class": "ZwavePowerSwitch"
    }
  ]

  class ZWavePlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      @debug = @config.debug || false
      @base = commons.base @, 'Plugin'
      deviceConfigDef = require("./device-config-schema")
      @protocolHandler = new ZwaveAppProtocol @config

      for device in deviceConfigTemplates
        className = device.class
          
        # convert camel-case classname to kebap-case filename
        filename = className.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()

        classType = require('./devices/' + filename)(env)

        @base.debug "Registering device class #{className}"
        @framework.deviceManager.registerDeviceClass(className, {
          configDef: deviceConfigDef[className],
          createCallback: @_callbackHandler(className, classType)
        })

      # auto-discovery
      @framework.deviceManager.on('discover', (eventData) =>
        @framework.deviceManager.discoverMessage 'pimatic-zwave-usb', 'Searching for zwave devices'

        @base.debug "Eventdata:", eventData
        @base.debug "devices: ", @protocolHandler.getDevices()

        for device in @protocolHandler.getDevices()

          #If the device is already added: don't show
          matched = @framework.deviceManager.devicesConfig.some (element, iterator) =>
            element.node is device?.nodeid

          if not matched
            deviceToText = device?.product

            # convert spaces to -
            id = deviceToText.replace(/(\s)/g, '-').toLowerCase()

            deviceClass = "ZwavePowerSwitch"

            if device?.classes["67"]
              deviceClass = "ZwaveThermostat"

            config = {
              id: id
              class: deviceClass,
              name: deviceToText,
              node: device?.nodeid
            }
            
            @framework.deviceManager.discoveredDevice(
              'pimatic-zwave-usb', "Presence of #{deviceToText}", config
            )
      )

    _callbackHandler: (className, classType) ->
      # this closure is required to keep the className and classType context as part of the iteration
      return (config, lastState) =>
        return new classType(config, @, lastState)

  #bamm done.
  return new ZWavePlugin