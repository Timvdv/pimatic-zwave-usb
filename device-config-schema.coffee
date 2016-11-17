module.exports = {
  title: "pimatic-zwave-usb device config schemas"
  ZwaveThermostat: {
    title: "ZWave config options"
    type: "object"
    properties:
      id:
        description: "unique ID"
        type: "string"
      name:
        description: "Name your device"
        type: "string"
      node:
        description: "The zwave nodeid"
        type: "integer"
      guiShowTemperatureInput:
        description: "Show the temperature input spinbox in the gui"
        type: "boolean"
        default: true
      guiShowValvePosition:
        description: "Show the valve position in the gui"
        type: "boolean"
        default: true
  }
}