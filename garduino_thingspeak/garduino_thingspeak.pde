/*

  Garduino using a thingspeak client to send the data to.
  
  Author: Andrew Fisher
  
  Version: 0.1
  
  Created: 11 September, 2011
  
  Usage: You'll need a thingspeak account (www.thingspeak.com), and a new channel to make it work.
          put in your details and you'll need to overwrite might API key to make it work
          
  Note: Because TS is limited to only 8 variables on a channel this example simply uploads the moisture vals
        leaving temp and light for the moment. If you don't have 8 moisture sensors then just flip out
        the last two or so and add temp and light in there too.
 
 Additional Credits: Example Thingspeak sketch from Hans Scharler
                     Example sketches from Tom Igoe and David A. Mellis
 
*/

#include <SPI.h>
#include <Ethernet.h>
#include <analogmuxdemux.h>

// Local Network Settings
byte mac[]     = { 0xD4, 0x28, 0xB2, 0xFF, 0xA0, 0xA1 }; // Must be unique on local network
byte ip[]      = { 10, 0,   1,  52 };                // Must be unique on local network
byte gateway[] = { 10, 0,   1,   1 };
byte subnet[]  = { 255, 255, 255,   0 };

// ThingSpeak Settings
byte server[]  = { 184, 106, 153, 149 }; // IP Address for the ThingSpeak API
String writeAPIKey = "4MCLENET5XXJ3Z28";    // Write API Key for a ThingSpeak Channel (You need to change this to your one)
const int updateInterval = 30000;        // Time interval in milliseconds to update ThingSpeak   
Client client(server, 80);

String thingspeakStr = "";

// Variable Setup
long lastConnectionTime = 0; 
boolean lastConnected = false;
int resetCounter = 0;

// Garduino set up
// Set up the analog sensors
#define MOISTURE 0
#define TEMP 1
#define LIGHT 2

#define NO_PINS 8 // number of input pins to look at.

AnalogMux amux(4,3,2, MOISTURE); // S0 D4, S1 D3, S2 D2


void setup()
{
  Ethernet.begin(mac, ip, gateway, subnet);
  Serial.begin(9600);
  delay(1000);
}

void loop()
{
  //String analogPin0 = String(analogRead(A0), DEC);
  
  // Print Update Response to Serial Monitor
  if (client.available())
  {
    char c = client.read();
    Serial.print(c);
  }
  
  // Disconnect from ThingSpeak
  if (!client.connected() && lastConnected)
  {
    Serial.println();
    Serial.println("...disconnected.");
    Serial.println();
    
    client.stop();
  }
  
  // Update ThingSpeak
  if(!client.connected() && (millis() - lastConnectionTime > updateInterval))
  {
    
    thingspeakStr = "";
    for (int pin=0; pin<NO_PINS; pin++){
      thingspeakStr += String(pin+1, DEC);
      thingspeakStr += "=" + String(amux.AnalogRead(pin), DEC);
      thingspeakStr += "&";
      Serial.print(pin);
      Serial.print(":");
      Serial.println(amux.AnalogRead(pin));
    }
    updateThingSpeak(thingspeakStr);
  }
  
  lastConnected = client.connected();
}

void updateThingSpeak(String tsData)
{
  if (client.connect())
  { 
    Serial.println("Connected to ThingSpeak...");
    Serial.println();
        
    client.print("POST /update HTTP/1.1\n");
    client.print("Host: api.thingspeak.com\n");
    client.print("Connection: close\n");
    client.print("X-THINGSPEAKAPIKEY: "+writeAPIKey+"\n");
    client.print("Content-Type: application/x-www-form-urlencoded\n");
    client.print("Content-Length: ");
    client.print(tsData.length());
    client.print("\n\n");

    client.print(tsData);
    
    lastConnectionTime = millis();
    
    resetCounter = 0;
    
  }
  else
  {
    Serial.println("Connection Failed.");   
    Serial.println();
    
    resetCounter++;
    
    if (resetCounter >=5 ) {resetEthernetShield();}

    lastConnectionTime = millis(); 
  }
}

void resetEthernetShield()
{
  Serial.println("Resetting Ethernet Shield.");   
  Serial.println();
  
  client.stop();
  delay(1000);
  
  Ethernet.begin(mac, ip, gateway, subnet);
  delay(1000);
}


