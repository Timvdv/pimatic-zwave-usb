# #pimatic-zwave-usb configuration options
# coffeelint: disable=max_line_length
module.exports = {
  title: "Options for pimatic zwave "
  type: "object"
  properties:
    usb:
      description: "the zwave usb port: COM{1} for Windows and /dev/ttyS{0} or /dev/ttyUSB{0} for Linux"
      type: "string"
      default: "/dev/cu.usbmodem1421",
    debug:
      description: "debug output on or off"
      type: "boolean"
      default: false
}