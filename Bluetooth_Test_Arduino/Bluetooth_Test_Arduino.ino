#include <SoftwareSerial.h>

int bluetoothTx = 3;  // TX-O pin of bluetooth mate
int bluetoothRx = 2;  // RX-I pin of bluetooth mate

SoftwareSerial bluetooth(bluetoothTx, bluetoothRx);

// how many velcro patches are there for this player?
int velcroCount = 2;
// what are the digital pins you are using? figure out order later...
int velcroPin[] = {6, 7};

void setup()
{
  //Serial.begin(57600);  // Begin the serial monitor at 9600bps
  Serial.begin(9600);  // Begin the serial monitor at 9600bps

  bluetooth.begin(115200);  // The Bluetooth Mate defaults to 115200bps
  bluetooth.print("$");  // Print three times individually
  bluetooth.print("$");
  bluetooth.print("$");  // Enter command mode
  delay(100);  // Short delay, wait for the Mate to send back CMD
  bluetooth.println("U,9600,N");  // Temporarily Change the baudrate to 9600, no parity
  // 115200 can be too fast at times for NewSoftSerial to relay the data reliably
  bluetooth.begin(9600);  // Start bluetooth serial at 9600
  
  // set all velcro switch pins to input
  for (int i = 0; i < velcroCount; i++) {
    // pull up to voltage so that by grounding the switch we get a closed circuit
    pinMode(velcroPin[i], INPUT);
  }
}

void loop()
{
  String temp = "";
  
  // check all pins, build string depending on whether they are on or off (1/0)
  for (int i = 0; i < velcroCount; i++) {
    int val = digitalRead(velcroPin[i]);
    if (val == HIGH) {
      temp += "0";
    } else {
      temp += "1";
    }
  }

  // always print new line to send out string
  bluetooth.println(temp);
  Serial.println(temp);

  delay(50);

}

