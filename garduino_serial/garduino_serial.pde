/**
  Multiplexed Garduino Sensor
  Author: Andrew Fisher 
          Adapted from various others in the public domain, notably
          an article in Make Magazine 18 (www.makezine.com) that discussed 
          a single version of this.
          
  Revision Date: 26 June 2011
  
  http://maker.ajfisher.me
  
  Version: 0.2


**/
#include <analogmuxdemux.h>

#define MOISTURE 0
#define TEMP 1
#define LIGHT 2

#define NO_PINS 8 // number of input pins to look at.

AnalogMux amux(4,3,2, MOISTURE); // S0 D4, S1 D3, S2 D2

void setup(){
  
  Serial.begin(9600);
  Serial.println("Begin");
}


void loop() {
  
  
  for (int pin=0; pin<NO_PINS; pin++){
    Serial.print("MOIST");
    Serial.print(pin);
    Serial.print(": ");
    Serial.println(amux.AnalogRead(pin));
  }
  
  Serial.print("TEMP: ");
  //Serial.println(analogRead(TEMP));

      float THERMR = 10000;
      float PAD = 10000;
      
      int rawval = analogRead(TEMP);
      long Resistance=((1024 * THERMR / rawval) - PAD); 
      float Temp = log(Resistance); // Saving the Log(resistance) so not to calculate  it 4 times later
      Temp = 1 / (0.001129148 + (0.000234125 * Temp) + (0.0000000876741 * Temp * Temp * Temp));
      Temp = Temp - 273.15;  // Convert Kelvin to Celsius
  Serial.println(Temp);    

  Serial.print("LIGHT: ");
  Serial.println(analogRead(LIGHT));
  
  delay(3000);
  
}



