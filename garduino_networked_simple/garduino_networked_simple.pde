/**
  Multiplexed Garduino Sensor networked with Web Server
  Author: Andrew Fisher 
  
  This web server version adapted from the Ethernet example in Arduino IDE from TOM IGOE and DAVID MELLIS
          
  Date: 26 June 2011
  
  http://maker.ajfisher.me
  
  Version: 0.2
**/


#include <SPI.h>
#include <Ethernet.h>
#include <analogmuxdemux.h>

// do the setup for the networking
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEE }; // make sure this is a unique MAC
byte ip[] = { 10,0,1, 52 }; // make sure this is correct for your LAN
byte gateway[] = {10,0,1,1};
byte subnet[] = { 255, 255, 0, 0 };

// Initialize the Ethernet server library
// with the IP address and port you want to use 
// (port 80 is default for HTTP):
Server server(80);

// Set up the analog sensors
#define MOISTURE 0
#define TEMP 1
#define LIGHT 2

#define NO_PINS 8 // number of input pins to look at.

AnalogMux amux(4,3,2, MOISTURE); // S0 D4, S1 D3, S2 D2

void setup(){
  
  Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();
}


void loop() {

  Client client = server.available();
  if (client) {
    process_connection(client);
  }
  
}


void process_connection(Client client) {
    // takes a client and then gets all the data values for it.

    // this client set up directly used from the Example code - thanks Arduino
    // team for building a good fast little server  
  
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();

          // DO OUR GARDUINO STUFF HERE
          output_data(client);
          break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } 
        else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();  
  
}

void output_data(Client client) {
  // this function just simply prints out all of the data into formatted HTML to 
  // the client that is passed to it
  client.print("<html><head><title>Garduino</title>");

  client.print("<link rel=\"stylesheet\" href=\"http://maker.ajfisher.me/garduino/styles.css\" media=\"screen\"/>");
  client.print("</html><body>");
  client.print("<h1>Garduino Data</h1>");
  client.print("<p>From networked <a href=\"http://github.com/ajfisher/garduino\">Garduino project</a></p>");
  client.print("<h2>Moisture</h2>");
  client.print("<ul id=\"moisture\">");
  for (int pin=0; pin<NO_PINS; pin++){
    client.print("<li><span class=\"sensor_name\">Pin: ");
    client.print(pin);
    client.print(" </span><span class=\"sensor_value\"> ");
    client.print(amux.AnalogRead(pin));
    client.print("</span></li>");
  }
  client.print("</ul>");

  client.print("<h2>Temperature</h2>");
  client.print("<p>");

  float THERMR = 10000;
  float PAD = 10000;

  int rawval = analogRead(TEMP);
  long Resistance=((1024 * THERMR / rawval) - PAD); 
  float Temp = log(Resistance); // Saving the Log(resistance) so not to calculate  it 4 times later
  Temp = 1 / (0.001129148 + (0.000234125 * Temp) + (0.0000000876741 * Temp * Temp * Temp));
  Temp = Temp - 273.15;  // Convert Kelvin to Celsius
  client.print(Temp);
  client.print("&deg;C</p>");

  client.print("<h2>Light</h2>");
  client.print("<p>");
  client.print(analogRead(LIGHT));
  client.print("</p>");
  client.print("</body></html>");
}

