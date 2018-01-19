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
      syncTimeout:
        description: "After this timeout the sync status is reset to false, in minutes"
        type: "integer"
        default: 0
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
  ZwaveDimmer: {
    title: "ZWave dimmer options"
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
      syncTimeout:
        description: "After this timeout the sync status is reset to false, in minutes"
        type: "integer"
        default: 0
  }
  ZwaveNetworkCommands: {
    title: "Z-wave network commands"
    description: "Some settings to heal your zwave network"
    type: "object"
    extensions: ["xLink", "xOnLabel", "xOffLabel"]
    properties:
      buttons:
        description: "The inputs to select from"
        type: "array"
        default: [
          {
            id: "HEAL"
          }
          {
            id: "ADD"
          }
          {
            id: "DELETE"
          }
          {
            id: "RESET"
          }
        ]
  }
}
