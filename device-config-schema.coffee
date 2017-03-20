module.exports = {
  title: "pimatic-zwave-usb device config schemas"
  ZwaveThermostat: {
    title: "ZWave thermostat options"
    type: "object"
    properties:
      node:
        description: "The zwave nodeid"
        type: "integer"
        default: 0
      guiShowTemperatureInput:
        description: "Show the temperature input spinbox in the gui"
        type: "boolean"
        default: true
      guiShowValvePosition:
        description: "Show the valve position in the gui"
        type: "boolean"
        default: true
  }
  ZwavePowerSwitch: {
    title: "ZWave powerswitch options"
    type: "object"
    properties:
      node:
        description: "The zwave nodeid"
        type: "integer"
        default: 0
  }
  ZwaveWindowSensor: {
    title: "ZWave window sensor options"
    type: "object"
    properties:
      node:
        description: "The zwave nodeid"
        type: "integer"
        default: 0
      contact:
        description: "state of the contact"
        type: "boolean"
      synced:
        description: "Pimatic and thermostat in sync"
        type: "boolean"
      battery:
        description: "Battery status"
        type: "string"
        enum: ["ok", "low"]
      temperature:
        label: "Temperature"
        description: "The temperature messarrured"
        type: "number"
        discrete: true
        unit: "°C"
  }
}