// This code is based on the examples included in MFRC522 library
// Modify to include the UIDs of the tags on your treadmill belt

#include<SPI.h>
#include<MFRC522.h>

//creating mfrc522 instance
#define RSTPIN 9
#define SSPIN 10
MFRC522 rc(SSPIN, RSTPIN);

int readsuccess;

/* the following are the UIDs of the card which are authorised
    to know the UID of your card/tag use the example code 'DumpInfo'
    from the library mfrc522 it give the UID of the card as well as 
    other information in the card on the serial monitor of the arduino*/

    //byte defcard[4]={0x32,0xD7,0x0F,0x2B}; // if you only want one card
byte defcard[][4]={{0xC4,0x11,0xCB,0xCF},{0xF4,0x2B,0xC9,0xCF},{0xE4,0x2B,0xC9,0xCF},{0xD4,0x2B,0xC9,0xCF},{0xC4,0x2B,0xC9,0xCF}}; //for multiple cards
//byte defcard[][4]={{0xC4,0x11,0xCB,0xCF},{0xF4,0x2B,0xC9,0xCF},{0xE4,0x2B,0xC9,0xCF},{0xD4,0x2B,0xC9,0xCF},{0xD4,0x19,0xC7,0xCF}}; //for reversal learning; ID of reward tag changed
int N=5; //change this to the number of cards/tags you will use
byte readcard[4]; //stores the UID of current tag which is read

void setup() {
//Serial.begin(9600); //for debugging purposes

SPI.begin();
rc.PCD_Init(); //initialize the receiver  
rc.PCD_DumpVersionToSerial(); //show details of card reader module

pinMode(6,OUTPUT); //Zone 1 digital output, match = 0, channel 6
pinMode(5,OUTPUT); //Zone 2 digital output, match = 1, channel 5
pinMode(4,OUTPUT); //Zone 3 digital output, match = 2, channel 4
pinMode(3,OUTPUT); //Zone 4 digital output, match = 3, channel 3
pinMode(2,OUTPUT); //Reward digital output, match = 4, channel 2

//if tag unrecognized match = 5


//Serial.println(F("Recognized RFID tags are")); //display authorised cards just to demonstrate you may comment this section out
//for(int i=0;i<N;i++){ 
//  Serial.print(i+1); for debugging purposes
//  Serial.print("  ");
//    for(int j=0;j<4;j++){
//      Serial.print(defcard[i][j],HEX);
//      }
//      Serial.println("");
//     }
//Serial.println("");
//
//Serial.println(F("Scanning for RFID tags..."));
}


void loop() {
  
readsuccess = getid();

if(readsuccess){
 
  int match=5;

//this is the part where compare the current tag with pre defined tags
  for(int i=0;i<N;i++){
    //Serial.print("Testing Against Authorised card no: ");
    //Serial.println(i+1);
    if(!memcmp(readcard,defcard[i],4)){
      match=i;
      }
    
  }
    
  
   if(match==0)
      {//Serial.println("Recognized tag detected: Zone 1");
        digitalWrite(6,HIGH);
        delay(500);
        digitalWrite(6,LOW);
        delay(300);   
      }

    if(match==1)
      {//Serial.println("Recognized tag detected: Zone 2");
        digitalWrite(5,HIGH);
        delay(500);
        digitalWrite(5,LOW);
        delay(300);  
      }

    if(match==2)
      {//Serial.println("Recognized tag detected: Zone 3");
        digitalWrite(4,HIGH);
        delay(500);
        digitalWrite(4,LOW);
        delay(300);  
      } 

     if(match==3)
      {//Serial.println("Recognized tag detected: Zone 4");
        digitalWrite(3,HIGH);
        delay(500);
        digitalWrite(3,LOW);
        delay(300);  
      } 

     if(match==4)
      {//Serial.println("Recognized tag detected: Reward");
        digitalWrite(2,HIGH);
        delay(500);
        digitalWrite(2,LOW);
        delay(300);  
      } 
      
     //if(match==5) {
      //Serial.println("Unrecognized tag detected");
      //}
  
  }
}
//function to get the UID of the card
int getid(){  
  if(!rc.PICC_IsNewCardPresent()){
    return 0;
  }
  if(!rc.PICC_ReadCardSerial()){
    return 0;
  }
 
  
  //Serial.println("THE UID OF THE SCANNED TAG IS:");
  
  for(int i=0;i<4;i++){
    readcard[i]=rc.uid.uidByte[i]; //storing the UID of the tag in readcard
    //Serial.print(readcard[i],HEX);
    
  }
   //Serial.println("");
   //Serial.println("Now Comparing with Authorised cards");
  rc.PICC_HaltA();
  
  return 1;
}
