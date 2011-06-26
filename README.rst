========
Garduino
========

This project was inspired heavily by a makezine article that looked at building a garden automation system to grow a plant including switching lights on and off etc. This version of it is more around the idea of an outdoor garden already that the user wants to have some interactions with. 

In this current iteration it is mostly oriented towards simply building a sensor array for moisture, temperature and light and logging that whether to a serial connection or making it available over the network.

Roadmap
=======

The long term plan for this project is to encompass the following:

- Using ZigBee to communicate to a base station to allow for non-wired comms
- Developing a reporting API to submit the data to various applications (this will probably be related to Pachube somehow)
- Have individual plants tweet or message otherwise when they need water
- Hook up to a weather feed in order to determine if the plants will need water
- Using solenoid valves to control a watering system to the individual plants.

Dependencies and usage
======================

All
---

- The AnalogMuxDeMux library available from github.com/ajfisher/arduino-analog-multiplexer/
- An Arduino (will work with Duemilanove or Uno or similar) fitted with a shield with schematic in this folder connect up to 8 probes, a temperature sensor and a light senor. 


Serial Garduino
---------------

An arduino connected to a serial port of the computer you want to log the data to. This is a good test to see that the shield it all working correctly and you are getting the right data. Also useful to ensure calibration of your thermistor.

Usage
.....

- Plug the shield (or attach the components via a breadboard) to the arduino and connect the arduino to your computer.
- Connect your various sensors
- Download the garduino_shield_demo.pde sketch and upload it to the arduino.
- Open up your serial monitor (in Arduino IDE or using a serial application such as screen from a Linux terminal)
- You should now see all the details coming from your various sensors. 

Networked Garduino Simple
-------------------------

An Arduiono connected to a network connection that you want to see the data it is reporting just like the serial version above. A good starting point to ensure your senor can network appropriately.

Dependencies
............

Get an Arduino Ethernet Shield such as the official many other, I personally prefer to use the EtherTen from FreeTronics as it gives you an Arduino and Ethernet on the same board which saves vertical height (http://www.freetronics.com/products/etherten)

Arduino networking is out of the scope of this doc, see the Arduino Playground for a good primer and also play with the Arduino IDE Ethernet examples to ensure your board is working. See http://www.arduino.cc/playground/Main/InterfacingWithHardware#ethernet for more.

Usage
.....

- 

