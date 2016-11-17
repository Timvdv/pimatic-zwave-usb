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
      "name": "zwave thermostat",
      "node": 0,
      "class": "ZwaveThermostat",
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
        for device in deviceConfigTemplates
          matched = @framework.deviceManager.devicesConfig.some (element, iterator) =>
            #@TODO: Autodiscovery
            console.log element.class is device.class, element.class, device.class
            element.class is device.class

          if not matched
            process.nextTick @_discoveryCallbackHandler('pimatic-zwave-usb', device.name, device)
      )

    _discoveryCallbackHandler: (pluginName, deviceName, deviceConfig) ->
      return () =>
        @framework.deviceManager.discoveredDevice pluginName, deviceName, deviceConfig

    _callbackHandler: (className, classType) ->
      # this closure is required to keep the className and classType context as part of the iteration
      return (config, lastState) =>
        return new classType(config, @, lastState)

  #bamm done.
  return new ZWavePlugin