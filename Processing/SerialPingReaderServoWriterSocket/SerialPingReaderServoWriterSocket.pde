// Example by Tom Igoe
//based on arduino_servo and http://processing.org/reference/libraries/net/Server_available_.html

import processing.net.*;
import processing.serial.*;

Serial myPort;  // The serial port
Serial myPort2;  // The serial port

int port = 6000;       
Server myServer;  

int j = 0;
int i = 0;
int inByte = 0;

void setup() {
  // List all the available serial ports:
  //println(Serial.list());
  // Open the port you are using at the rate you want:
  //myPort = new Serial(this, Serial.list()[4], 9600);
  myPort = new Serial(this, "/dev/tty.usbmodem12341", 115200);
  //myPort2 = new Serial(this, "/dev/tty.usbmodem1421", 9600);
  println("Started...");

  myServer = new Server(this, port);
}

void draw() {
  while (myPort.available () > 0) {
    inByte = myPort.read();
    //println("Received " + inByte);

    //myPort2.write((byte)(inByte*3));
    //String myString = myPort.readStringUntil('\n');
    //if (myString != null) {
    //println(myString);
    //}
  }

  /*
  if ((i++)%1 == 0) {
   j+=10;
   myPort.write(j);
   if (j >= 181)
   j = 0;
   }
   */

  delay(50);


  /*
  for (int i = 0; i < 100; i++) {
   myPort.write(i);
   //myPort.write('\n');
   while (myPort.available () > 0) {
   int inByte = myPort.read();
   println(inByte);
   }
   delay(100);
   }
   */
  //exit();

  // Get the next available client
  Client thisClient = myServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    //println("Client's IP is " + thisClient.ip());

    //thisClient.println("Distance = " + (int)inByte);
    //thisClient.write(inByte);
    //thisClient.write('\n');

    String whatClientSaid = thisClient.readStringUntil('\n');
    if (whatClientSaid != null) {
      print("whatClientSaid: " + whatClientSaid);
      //int degree = Integer.parseInt(whatClientSaid.trim());
      //println("degree = " + degree);
      //arduino.servoWrite(7, constrain(degree, 0, 180));
    }
  }
}

