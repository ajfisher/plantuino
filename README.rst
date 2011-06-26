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


