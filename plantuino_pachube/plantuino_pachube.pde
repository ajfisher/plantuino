/*

  Multiplexed Plantuino Sensor uploading data to Pachube.
  
  Author: Andrew Fisher
          
  Date: 14 December 2011
  
  http://maker.ajfisher.me
  
  Version: 0.3

  Uses the Arduino Pachube library, ERxPachube. See http://code.google.com/p/pachubelibrary/ for more details
  and to get the library.
  
  you'll need a pachube account and api key: http://www.pachube.com
  
  You don't need a paid account with Pachube any more so have as many feeds as you'd like.
  
  Create a feed using the structure as per http://pachube.com/feeds/21503

  requires ethernet connection

*/
//#define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINT(x)     Serial.print (x)
  #define DEBUG_PRINTDEC(x)     Serial.print (x, DEC)
  #define DEBUG_PRINTLN(x)  Serial.println (x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTDEC(x)
  #define DEBUG_PRINTLN(x)
#endif  


#include "ERxPachube.h"
#include <Ethernet.h>
#include <SPI.h>
#include <analogmuxdemux.h>
#include "config.h" //config file for you to stick all your data into - check config.h.sample for reqs.


ERxPachubeDataOut dataout(PACHUBE_API_KEY, PACHUBE_FEED_ID);



// Set up the analog sensors
#define MOISTURE 0
#define TEMP 1
#define LIGHT 2

#define NO_PINS 8 // number of input pins to look at.

AnalogMux amux(4,3,2, MOISTURE); // S0 D4, S1 D3, S2 D2

void PrintDataStream(const ERxPachube& pachube);

#define MASTER_RESET_COUNT 60
#define TIME_BETWEEN_UPDATES 60000

int resetCounter = 0;
int noPosts = 0; // used to see how many times we've posted. If we get to 60 then do a reset anyway.


void setup() {

        #ifdef DEBUG
          Serial.begin(9600);
        #endif
	Ethernet.begin(mac, ip);

        for (int i=0; i<10; i++){
        	dataout.addData(i);
        }
}

void loop() {

	DEBUG_PRINTLN("+++++++++++++++++++++++++++++++++++++++++++++++++");

        get_readings();
        
	int status = dataout.updatePachube();

        DEBUG_PRINT("sync status code <OK == 200> => ");
	DEBUG_PRINTLN(status);
        
        if (status == 200) {
              PrintDataStream(dataout);
              resetCounter = 0;
              noPosts++;
              if (noPosts > MASTER_RESET_COUNT) {
                noPosts = 0;
                resetEthernetShield();
              }
        } else {
            resetCounter++;
            if (resetCounter > 5) { resetEthernetShield(); }
        }



        double waittime = TIME_BETWEEN_UPDATES;
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
  DEBUG_PRINT("Temp: ");
  DEBUG_PRINTLN(Temp);
  
  dataout.updateData(0, Temp);
  
  // now light
  DEBUG_PRINT("Light: ");
  DEBUG_PRINTLN(analogRead(LIGHT));
  dataout.updateData(1, analogRead(LIGHT));
  
  // now we iterate over the moisture sensors
  DEBUG_PRINTLN("Moisture:");
  for (int pin = 0; pin<NO_PINS; pin++) {
    DEBUG_PRINT("Channel ");
    DEBUG_PRINT(pin);
    DEBUG_PRINT(": ");
    DEBUG_PRINTLN(amux.AnalogRead(pin));
    dataout.updateData(pin+2, amux.AnalogRead(pin));
  }

  
}


void PrintDataStream(const ERxPachube& pachube)
{
	unsigned int count = pachube.countDatastreams();
	DEBUG_PRINT("data count=> ");
	DEBUG_PRINTLN(count);

	DEBUG_PRINTLN("<id>,<value>");
	for(unsigned int i = 0; i < count; i++)
	{
		DEBUG_PRINT(pachube.getIdByIndex(i));
		DEBUG_PRINT(",");
		DEBUG_PRINT(pachube.getValueByIndex(i));
		DEBUG_PRINTLN();
	}
}

void resetEthernetShield()
{
  DEBUG_PRINTLN("Resetting Ethernet Shield.");   
  
  delay(5000);
  Ethernet.begin(mac, ip, gateway, subnet);
  delay(5000);
}
