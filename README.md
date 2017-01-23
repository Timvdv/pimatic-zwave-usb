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
You will also need a ZWave USB stick. I tested this with the [The Aeotec Z-Stick Gen5](http://aeotec.com/z-wave-usb-stick). I think other zwave sticks will also work.

I used a Danfoss LC13 and a power plug for testing the devices. 


## What can this plugin do?
- Control Devices
    - Power switch _(class id: 32)_
    - Thermostat _(class id: 67)_
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

### thermostat device
```
    {
      "id": "zwave-thermostat",
      "name": "ZWave Thermostat",
      "node": 4,
      "class": "ZwaveThermostat"
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