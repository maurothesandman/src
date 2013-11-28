//based on arduino_servo and http://processing.org/reference/libraries/net/Server_available_.html

import processing.net.*;
import processing.serial.*;

int port = 6000;       
Server myServer;  

import cc.arduino.*;

Arduino arduino;

void setup() {
  size(360, 200);

  myServer = new Server(this, port);

  // Prints out the available serial ports.
  println(Arduino.list());

  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  //arduino = new Arduino(this, Arduino.list()[0], 9600);
  arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);

  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);

  // Configure digital pins 4 and 7 to control servo motors.
  arduino.pinMode(4, Arduino.SERVO);
  arduino.pinMode(7, Arduino.SERVO);
}

void draw() {
  background(constrain(mouseX / 2, 0, 180));

  // Get the next available client
  Client thisClient = myServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    String whatClientSaid = thisClient.readStringUntil('\n');
    if (whatClientSaid != null) {
      print("whatClientSaid: " + whatClientSaid);
      int degree = Integer.parseInt(whatClientSaid.trim());
      println("degree = " + degree);
      arduino.servoWrite(7, constrain(degree, 0, 180));
    }
  }
}

