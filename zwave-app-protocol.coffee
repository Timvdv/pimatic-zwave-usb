# HttpAppProtocol class
# coffeelint: disable=max_line_length

module.exports = (env) ->
  Promise = env.require 'bluebird'
  _ = env.require 'lodash'

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

      @nodes = []
      @deviceDiscovery = []

      @zwave = new ZWave({
        ConsoleOutput: @debug
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

      @zwave.on "node added", (nodeid) =>
        #@base.debug('=================== NODE ADDED! ====================')
        @nodes[nodeid] = {
          nodeid: nodeid
          manufacturer: ''
          manufacturerid: ''
          product: ''
          producttype: ''
          productid: ''
          type: ''
          name: ''
          loc: ''
          classes: {}
          ready: false
        }

      @zwave.on "value added", (nodeid, commandclass, value) =>
        @nodes[nodeid]?.classes[commandclass] = value
        #@base.debug "node: ", @nodes[nodeid]
        #@base.debug "nodes: ", @nodes

      @zwave.on "value changed", (nodeid, commandclass, value) =>
        #@base.debug "changed: ", value
        @_triggerResponse(value, nodeid)

        if @nodes[nodeid]?.ready
          for node in @nodes[nodeid]?.classes
            if node.index is value.index
              node.index = value

      @zwave.on "node ready", (nodeid, nodeinfo) =>
        if !nodeinfo
          return @base.debug "node: ", nodeid, " has no node information"

        @nodes[nodeid] = {
          nodeid: nodeid
          manufacturer: nodeinfo.manufacturer
          manufacturerid: nodeinfo.manufacturerid
          product: nodeinfo.product
          producttype: nodeinfo.producttype
          productid: nodeinfo.productid
          type: nodeinfo.type
          name: nodeinfo.name
          loc: nodeinfo.loc
          classes: @nodes[nodeid].classes
          ready: true
        }

        @base.debug "info: ", nodeid

        for commandClass in @nodes[nodeid]?.classes
          @base.error "Commandclass: ",commandClass
          switch commandClass
            when 0x25 or 0x26 or 0x27
              @zwave.enablePoll(nodeid, commandClass)

        @deviceDiscovery.push(@nodes[nodeid])

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

    sendRequest: (command, value, type="switch") =>
      return new Promise (resolve, reject) =>
        @base.debug "Command:", command, "value: ", value
        @zwave.setValue(command, value)

        resolve()

    addNodes: () =>
      return new Promise (resolve, reject) =>
        @zwave.addNode(false)
        resolve()
        
    getDevices: () =>
      return @deviceDiscovery
