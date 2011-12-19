/**

  Web Controlled Remote Watering system

  Date: 19 December, 2011
  
  Version: 0.1

  See README for full implementation notes and licence
  
  Circuit derived from @jonoxer's Relay Shield design to control wireless remote controlled power sockets. 
  (http://www.practicalarduino.com/projects/appliance-remote-control)
  
  Code derived from Generic Network Pulser sketch that sets up ReSTful URLs to trigger actions.
  (https://gist.github.com/1290670)

**/
#define DEBUG
#ifdef DEBUG
  #define DEBUG_PRINT(x)     Serial.print (x)
  #define DEBUG_PRINTDEC(x)     Serial.print (x, DEC)
  #define DEBUG_PRINTLN(x)  Serial.println (x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTDEC(x)
  #define DEBUG_PRINTLN(x)
#endif 

#include <SPI.h>
#include <Ethernet.h>
#include "network.h"

// Initialize the Ethernet server library
// with the IP address and port you want to use 
// (port 80 is default for HTTP):
Server server(80);

#define BUFFERLENGTH 255

// define how many channles you want to use. Mapped to number of switches you want to control
#define MAX_CHANNELS 2 

// number of milliseconds to wait between each increment of fade. 
#define PULSE_WAIT 500

// maximum number of requests to wait for before restarting ethernet
#define REQUESTS_RESET 5

int channels[MAX_CHANNELS]; // This is a mapping of channel numbers to pin numbers

int request_count = 0;

void setup() {
  Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();
  
  // set up each of your channels here as
  channels[0] = 2; // etc this will point channel 0 to pin 2
  channels[1] = 3; // 
  

  // set up each of the channels as an output.
  for (int i=0; i<MAX_CHANNELS; i++) {
    if (channels[i] > 0) {
      
      pinMode(channels[i], OUTPUT);
      digitalWrite(channels[i], LOW);
    }
  }

  
  #ifdef DEBUG
  Serial.begin(9600);
  #endif
  
  DEBUG_PRINTLN("Awaiting connection");
  
}

void loop() {

  char buffer[BUFFERLENGTH];
  int index = 0;
  
  // Listen
  Client client = server.available();
  if (client) {
    DEBUG_PRINTLN("Got a client");
    // reset the input buffer
    index = 0;  
    request_count++;
    while (client.connected()) {
      if (client.available()){
        char c = client.read();
        
        // if it's not a new line then add it to the buffer
        if (c != '\n' && c != '\r') {
          buffer[index] = c;
          index++;
          
          if (index > BUFFERLENGTH) index = BUFFERLENGTH -1;
          
          continue;
        }
        
        // get the url string for processing
        String urlstr = String(buffer);
                
        // get just the url
        urlstr = urlstr.substring(urlstr.indexOf('/'), urlstr.indexOf(' ', urlstr.indexOf('/')));
        
        // rebuild the buffer with just the URL
        urlstr.toCharArray(buffer, BUFFERLENGTH);
        
        // now we get the parameters channel to pulse and time to pulse it
        char *channel = strtok(buffer, "/");
        //char *time = strtok(NULL, "/");
        
        int selectedChannel = channel[0] - '0'; // convert to int
        
        if (channel == NULL || selectedChannel >= MAX_CHANNELS) {
          // return error
          client.println("HTTP/1.1 404 Not Found");
          client.println("Content-Type: text/html");
          client.println();
          DEBUG_PRINTLN("Error 404 not found");
          DEBUG_PRINTLN(urlstr);
        } else {
          // Got the URL - now we pulse the switch and return the HTTP response
          
          pulse_wireless_switch(channels[selectedChannel]);

          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          
          DEBUG_PRINTLN("200 OK");
        
        }
        
        break;
      }
    }
    
    delay(10); // give client time to send the data back
    DEBUG_PRINTLN("Stopping client");
    client.stop();
    if (request_count > REQUESTS_RESET) {
      request_count = 0;
      resetEthernetShield();
    }
  }
  
  

  delay(5);
  
}


void pulse_wireless_switch(int pin) {
  // this method pulses a switch for the wireless remote, by *pressing* the button for 3 bursts of
  // about 200msec each... just to make sure it's toggled.

  DEBUG_PRINT("Pulsing: ");
  DEBUG_PRINTLN(pin);

  int no_pulses = 1; // pulse 3 times;
  
  for (int i =0; i< no_pulses; i++) {
    digitalWrite(pin, HIGH);
    delay(PULSE_WAIT);
    DEBUG_PRINTLN("PULSE");
    digitalWrite(pin, LOW);
    delay(PULSE_WAIT);
  }
}

void resetEthernetShield()
{
  DEBUG_PRINTLN("Resetting Ethernet Shield.");   
  
  delay(5000);
  Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();
  delay(5000);
}

