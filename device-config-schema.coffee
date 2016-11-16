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
  }
}