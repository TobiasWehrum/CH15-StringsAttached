#include <SoftwareSerial.h>

int bluetoothTx = 3;  // TX-O pin of bluetooth mate
int bluetoothRx = 2;  // RX-I pin of bluetooth mate

SoftwareSerial bluetooth(bluetoothTx, bluetoothRx);

/*
  AnalogReadSerial
  Reads an analog input on pin 0, prints the result to the serial monitor.
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.
 
 This example code is in the public domain.
 */
  int sensors[6] = {0,0,0,0,0,0}; 
  int previousData[6] = {8,8,8,8,8,8};
  int currentData[6] = {0,0,0,0,0,0};
  int i = 0;
  int gameState;
  boolean isConnected = false;
  boolean wasConnected = false;
  int previous_1 = 0;
  int previous_2 = 0;
  int current_1 = 0;
  int current_2 = 0;
  int count = 0;
  
  
// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
   Serial.begin(9600);  
   
   
  bluetooth.begin(115200);  // The Bluetooth Mate defaults to 115200bps
  bluetooth.print("$");  // Print three times individually
  bluetooth.print("$");
  bluetooth.print("$");  // Enter command mode
  delay(100);  // Short delay, wait for the Mate to send back CMD
  bluetooth.println("U,9600,N");  // Temporarily Change the baudrate to 9600, no parity
  // 115200 can be too fast at times for NewSoftSerial to relay the data reliably
  bluetooth.begin(9600);  // Start bluetooth serial at 9600
  
  
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  sensors[0] = analogRead(A0);
  sensors[1] = analogRead(A1);
  sensors[2] = analogRead(A2);
  sensors[3] = analogRead(A3);
  sensors[4] = analogRead(A4);
  sensors[5] = analogRead(A5);
  gameState = digitalRead(4);

  //Serial.println(); Serial.print(sensors[1]); delay(1); return;
    
  for(i = 0; i < 6; i++){
    if(sensors[i] != 0){
       int n = inputData(sensors[i]);
       currentData[i] = n;            
    }
    if (sensors[i] == 0){
      currentData[i] = 0;
    } 
  }
  
  if((previousData[0]!=currentData[0])||(previousData[1]!=currentData[1])||
  (previousData[2]!=currentData[2])||(previousData[3]!=currentData[3])||(previousData[4]!=currentData[4]
  ||(previousData[5]!=currentData[5]))){
    output();
    
    
    
  }
  
  //output(); 
  /*
  if(!playerConnection()){
    Serial.println("disconnected");
  }
  */

  isConnected = playerConnection();
  if (isConnected != wasConnected)
  {
    if (isConnected)
    {
      Serial.println("+");
      bluetooth.println("+");
    }
    else
    {
      Serial.println("-");
      bluetooth.println("-");
    }
  }
   
   wasConnected = isConnected;
   
   delay(1);        // delay in between reads for stability
}
 
  void output(){
     for(int x = 0; x < 6; x++){ 
     Serial.print(currentData[x]);
     bluetooth.print(currentData[x]);
     previousData[x] = currentData[x]; 
   }
     Serial.println();
     bluetooth.println();
  }


  boolean playerConnection() {
  
    if(gameState == 1){
    return true;
  }
  else{ 
    return false;
  }
  } 
  
  
  int inputData(int _number){
    if(_number < 5){ // old: 20
      return 0;
    }

    int tolerance = 10;
    
    if(_number < 42 + tolerance){ // old: 50; read wires: 42
      return 1;  
    }   
    
    if(_number < 178 + tolerance){ // old: 150; read wires: 178
      return 2;  
    }  
    
    if( _number < 319 + tolerance){ // old: 250; read wires: 319
      return 3;  
    }       
    
    if( _number < 512 + tolerance){ // old: 350; read wires: 512
      return 4;  
    }   
  
    if( _number < 696 + tolerance){ // old: 480; read wires: 696
      return 5;  
    }

  return 6;  // read wires: 1023
       
    
  
  }

