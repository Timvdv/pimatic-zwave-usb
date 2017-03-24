zwave-usb-plugin
=======================

## Prerequisites
**important notice**

openzwave needs to be installed on your system before you can use this plugin!!
Please read this first: [node-openzwave-shared](https://github.com/OpenZWave/node-openzwave-shared)

It has lots of README files which guide you through the installation process.
- [Raspbian](https://github.com/OpenZWave/node-openzwave-shared/blob/master/README-raspbian.md)
- [Ubuntu](https://github.com/OpenZWave/node-openzwave-shared/blob/master/README-ubuntu.md)
- Check the [repository](https://github.com/OpenZWave/node-openzwave-shared) for more information


## Equipment
You will also need a ZWave USB stick.
- Tested with the [The Aeotec Z-Stick Gen5](http://aeotec.com/z-wave-usb-stick).
- Tested with a Z-wave plus USB stick Model name: ZU1401EU.
I think other zwave sticks will also work.

Tested Z-wave deviced
- Danfoss LC13
- a power plug
- Door/Window sensor from Devolo. This device has a contact sensor, temperature sensor and lightness sensor included.

## What can this plugin do?
- Control Devices
    - Power switch _(class id: 32)_
    - Thermostat _(class id: 67)_
    - Door/Window Sensor _(class id: 49)_
      - contact and temperature support

- Auto-discover ZWave devices

View all [command classes](http://wiki.micasaverde.com/index.php/ZWave_Command_Classes)


## Plugin settings in Pimatic
Example USB port for Linux: '/dev/ttyUSB0'
Example USB port for Windows '\\\\.\\COM3'

```
    {
      "plugin": "zwave-usb",
      "usb": "/dev/ttyUSB0",
      "debug": false
    }
```


## Device settings in Pimatic
I suggest using auto-discovery but if you want to add it manually:

For a thermostat or a window contact sensor its possible to configure a sync timeout. This means that in case the z-wave device didnt update his values in this timeframe (configured in minutes) then the device is not synced anymore with pimatic.

### thermostat device
```
    {
      "id": "zwave-thermostat",
      "name": "ZWave Thermostat",
      "node": 4,
      "class": "ZwaveThermostat"
      "syncTimeout": 45
    }
```


### PowerSwitch device
```
    {
      "id": "zwave-switch",
      "name": "ZWave PowerSwitch",
      "node": 5,
      "class": "ZwavePowerSwitch"
    }
```

### door window contact sensor
```
    {
      "id": "zwave-window-sensor",
      "name": "ZWave WindowSensor",
      "node": 3,
      "class": "ZwaveWindowSensor"
      "syncTimeout": 45
    }
```

## Note

I kept getting the error `"libopenzwave.so.1.4" in the "/usr/local/lib64"`
Searched for this on Google and found the following solution (I use Ubuntu 14.04 so not sure if this will work for every system):

```
  sudo ldconfig /usr/local/lib64
```

I automated this by adding `ldconfig /usr/local/lib64` to my Pimatic startup script.

## To-do
- [x] PowerSwitch device
- [x] Thermostat device
- [x] Automatic device discovery
- [ ] Include/Exclude devices with Software
- [ ] Reset Z-wave network / Heal Z-wave network


## Support more devices
In the future I definitely want to support more devices.
I only have two ZWave devices at the moment, If you want me to implement more devices
you can donate them. Just send me a message on the Pimatic forum. You can also extend the plugin yourself,
just create a pull request!
