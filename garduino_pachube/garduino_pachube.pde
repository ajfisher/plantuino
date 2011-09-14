/*

  Multiplexed Garduino Sensor uploading data to Pachube.
  
  Author: Andrew Fisher
          
  Date: 15 September 2011
  
  http://maker.ajfisher.me
  
  Version: 0.1

  Uses the Arduino Pachube library, ERxPachube. See http://code.google.com/p/pachubelibrary/ for more details
  and to get the library.
  
  you'll need a pachube account and api key: http://www.pachube.com
  
  If you don't have a paid account then you'll only be able to sync 4 data streams. The library will take care of this and
  so will pachube as they will just ignore the remaining ones. You can see what comes back in the status.
  
  Create a feed using the structure as per http://pachube.com/feeds/21503

  requires ethernet connection


*/

#include "ERxPachube.h"
#include <Ethernet.h>
#include <SPI.h>
#include <analogmuxdemux.h>

byte mac[] = { 0xCC, 0xAC, 0xBE, 0xEF, 0xFE, 0x91 }; // make sure this is unique on your network
byte ip[] = { 10,0,1, 52 }; // make sure this is correct for your LAN
byte gateway[] = {10,0,1,1};
byte subnet[] = { 255, 255, 0, 0 };

#define PACHUBE_API_KEY				"PUT YOUR KEY IN HERE"// fill in your API key PACHUBE_API_KEY
#define PACHUBE_FEED_ID				21503 // fill in your feed id

ERxPachubeDataOut dataout(PACHUBE_API_KEY, PACHUBE_FEED_ID);



// Set up the analog sensors
#define MOISTURE 0
#define TEMP 1
#define LIGHT 2

#define NO_PINS 8 // number of input pins to look at.

AnalogMux amux(4,3,2, MOISTURE); // S0 D4, S1 D3, S2 D2


void PrintDataStream(const ERxPachube& pachube);

void setup() {

	Serial.begin(9600);
	Ethernet.begin(mac, ip);

        for (int i=0; i<10; i++){
        	dataout.addData(i);
        }

}

void loop() {

	Serial.println("+++++++++++++++++++++++++++++++++++++++++++++++++");

        get_readings();
        
	int status = dataout.updatePachube();

	Serial.print("sync status code <OK == 200> => ");
	Serial.println(status);

	PrintDataStream(dataout);
        double waittime = 60000;
	delay(waittime);
}

void get_readings() {
  
  // temperature is first

  float THERMR = 10000;
  float PAD = 10000;

  int rawval = analogRead(TEMP);
  long Resistance=((1024 * THERMR / rawval) - PAD); 
  float Temp = log(Resistance); // Saving the Log(resistance) so not to calculate  it 4 times later
  Temp = 1 / (0.001129148 + (0.000234125 * Temp) + (0.0000000876741 * Temp * Temp * Temp));
  Temp = Temp - 273.15;  // Convert Kelvin to Celsius
  Serial.print("Temp: ");
  Serial.println(Temp);
  
  dataout.updateData(0, Temp);
  
  // now light
  Serial.print("Light: ");
  Serial.println(analogRead(LIGHT));
  dataout.updateData(1, analogRead(LIGHT));
  
  // now we iterate over the moisture sensors
  Serial.println("Moisture:");
  for (int pin = 0; pin<NO_PINS; pin++) {
    Serial.print("Channel ");
    Serial.print(pin);
    Serial.print(": ");
    Serial.println(amux.AnalogRead(pin));
    dataout.updateData(pin+2, amux.AnalogRead(pin));
  }

  
}


void PrintDataStream(const ERxPachube& pachube)
{
	unsigned int count = pachube.countDatastreams();
	Serial.print("data count=> ");
	Serial.println(count);

	Serial.println("<id>,<value>");
	for(unsigned int i = 0; i < count; i++)
	{
		Serial.print(pachube.getIdByIndex(i));
		Serial.print(",");
		Serial.print(pachube.getValueByIndex(i));
		Serial.println();
	}
}
