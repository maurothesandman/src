#include <Servo.h> 

Servo myservo;  // create servo object to control a servo 

int incomingByte = 0;
int i = 0;    // variable to store the servo position 

void setup() {
  // initialize serial communication:
  Serial.begin(9600);
  myservo.attach(0);  // attaches the servo on pin 9 to the servo object 
}

void loop()
{
  delay(15);
}

/*
SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  if (Serial.available() > 0) {
    // lee el byte entrante:
    incomingByte = Serial.read();
    myservo.write(incomingByte);
    //Serial.write(incomingByte);

  }
}


