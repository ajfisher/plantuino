========
Garduino
========

This project was inspired heavily by a makezine article that looked at building a garden automation system to grow a plant including switching lights on and off etc. This version of it is more around the idea of an outdoor garden already that the user wants to have some interactions with. 

In this current iteration it is mostly oriented towards simply building a sensor array for moisture, temperature and light and logging that whether to a serial connection or making it available over the network.

Examples also include pushing data to Pachube and Thingspeak in order to capture and display the data using a web service.

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

An Arduino connected to a network connection that you want to see the data it is reporting just like the serial version above. A good starting point to ensure your senor can network appropriately.

Dependencies
............

Get an Arduino Ethernet Shield such as the official one or any other, I personally prefer to use the EtherTen from FreeTronics as it gives you an Arduino and Ethernet on the same board which saves vertical height (http://www.freetronics.com/products/etherten)

Arduino networking is out of the scope of this doc, see the Arduino Playground for a good primer and also play with the Arduino IDE Ethernet examples to ensure your board is working. See http://www.arduino.cc/playground/Main/InterfacingWithHardware#ethernet for more.

Usage
.....

- Plug the garduino circuit into the ethernet / arduino combination - ensure your ethernet shield has worked on your network first so as to reduce possible bugs.
- Open up garduino_networked_simple.pde and set a MAC address that is unique on your network as well as setting the IP, subnet and gateway bytes as per your LAN
- Save and upload the code to your arduino.
- Open a web browser and go to the IP address that you specified in your code. You should get a page that displays the current state of your code. Note that there is a reference in there to a style sheet on my server so you don't need to serve it from your arduino... 

Thingspeak Garduino
--------------------

An Arduino connected to the Internet that pushes data up to Thingpseak for display or other usage.

Dependencies
............

- A Garduino set up that functions as per the Networked Simple Garduino set up above.
- A user account on Thingspeak (http://www.thingspeak.com)
- Your write key from Thingspeak

Usage
......

- Plug the garduino circuit into the ethernet / arduino combination - ensure your ethernet shield has worked on your network first so as to reduce possible bugs.
- Open up garduino_thingspeak.pde and set a MAC address that is unique on your network as well as setting the IP, subnet and gateway bytes as per your LAN
- Set your API write key as per instructions in the code.
- Save and upload the code to your arduino.
- You should now be able to go to your feed on Thingspeak and see your data flowing in.

Pachube Garduino
-----------------

An Arduino connected to the Internet that pushes data up to Pachube for display or other usage such as setting triggers for events etc.

Dependencies
............

- A Garduino set up that functions as per the Networked Simple Garduino set up above.
- A user account on Pachube (http://www.pachube.com). Note a free account is sufficient but you can only have 5 data streams.
- Your Pachube API key
- Your Pachube Feed ID
- Download and install the Pachube library ERxPachube (http://code.google.com/p/pachubelibrary/) This abstracts a lot of the details of pushing up the data - makes it nice and quick and easy to use.


Usage
.....

- Open up ERxPachube.h in the ERxPachube library folder and modify the line that says::

    #define MAX_DATASTREAM_NUM 4
    
    to be::
    
    #define MAX_DATASTREAM_NUM 10
    
- Plug the garduino circuit into the ethernet / arduino combination - ensure your ethernet shield has worked on your network first so as to reduce possible bugs.
- Open up garduino_pachube.pde and set a MAC address that is unique on your network as well as setting the IP, subnet and gateway bytes as per your LAN
- Set your API key as per instructions in the code.
- Set your Feed ID as per instructions in the code
- Save and upload the code to your arduino.
- You should now be able to go to your feed on Pachube and see your data flow in


