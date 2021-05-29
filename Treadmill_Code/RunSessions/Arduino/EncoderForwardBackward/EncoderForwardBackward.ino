// This code is based on the Janelia Encoder Interface for Mouse Treadmill
// by Steve Sawtelle (Janelia Research Campus)
// The original code can be obtained here: 
// https://www.janelia.org/open-science/encoder-interface-for-mouse-treadmill
// 
// The original file was modified so that it runs on Arduino Due and encodes both Backward and Forward motion
// Modified by Tiago Goncalves
// 
//
//EncoderInterfaceT3
//
//  Read the encoder and translate to a distance and send over USB-Serial and DAC
//  Teensy 3.2 Arduino 1.8.3 with Teensy Extensions
//
//  This designed to be easy to assemble. The cables are soldered directly to Teensy 3.2.
//  Encoder A - pin 3
//  Encoder B - pin 4
//  Encoder VCC - Vin
//  Encoder ground - GND
//  Analog Out - A1/DAC
//  Analog ground - AGND
//
// Steve Sawtelle
// jET
// Janelia
// HHMI 
//

#define VERSION "20180207 - modified by Goncalves Lab"
// ===== VERSIONS ======

#define MAXSPEED    1000.0f  // maximum speed for dac out (mm/sec)
#define MAXDACVOLTS 2.5f    // DAC ouput voltage at maximum speed
#define MAXDACCNTS 4095.0f // maximum dac value

float maxDACval = MAXDACVOLTS * MAXDACCNTS / 3.3; // limit dac output to max allowed

#define encAPin 3
#define encBPin 4
#define dacPin  DAC1
//#define idxPin  2  // not used here

// counts per rotation of treadmill encoder wheel
// 200 counts per rev
// 1.03" per rev
// so - 1.03 * 25.4 * pi / 200 /1000 = microns/cnt

#define MM_PER_COUNT 410950  // actually 1/10^6mm per count since we divide by usecs
#define DIST_PER_COUNT ((float)MM_PER_COUNT/1000000.0)
//(float)0.41095

#define SPEED_TIMEOUT 50000  // if we don't move in this many microseconds assume we are stopped

static float runSpeed = 0;
static float lastSpeed = 0;
volatile uint32_t lastUsecs;
volatile uint32_t thisUsecs;
volatile uint32_t encoderUsecs;
volatile float distance = 0;

#define FW 1
#define BW -1
int dir = FW;

// ------------------------------------------
// interrupt routine for ENCODER_A rising edge
// ---------------------------------------------
void encoderInt()
{   
  int ENCA = digitalRead(encAPin);  // always update output 
  int ENCB = digitalRead(encBPin); 
  if (ENCA == ENCB )    // figure out the direction  
  {   
 //   Serial.print('B');
    dir = BW;
    thisUsecs = micros();
    encoderUsecs = thisUsecs - lastUsecs;
    lastUsecs = thisUsecs;
    runSpeed = (float)MM_PER_COUNT / encoderUsecs;
    distance -= DIST_PER_COUNT;
  }  
  else
  {
 //   Serial.print('F');
    dir = FW;
    thisUsecs = micros();
    encoderUsecs = thisUsecs - lastUsecs;
    lastUsecs = thisUsecs;
    runSpeed = (float)MM_PER_COUNT / encoderUsecs;
    distance += DIST_PER_COUNT;
  }  
}


void setup()
{
  Serial.begin(19200);
  while( !Serial);   // if no serial USB is connected, may need to comment this out
  pinMode(encAPin, INPUT_PULLUP); // sets the digital pin as input
  pinMode(encBPin, INPUT_PULLUP); // sets the digital pin as input
  analogWriteResolution(12);

  Serial.print("Treadmill Interface V: ");
  Serial.println(VERSION);
  Serial.println("distance,speed");
  Serial.println(maxDACval);

  lastUsecs = micros();
  attachInterrupt(encAPin, encoderInt, RISING); // check encoder every A pin rising edge
}

void loop() 
{ 
  noInterrupts();
  uint32_t now = micros();
  uint32_t lastU = lastUsecs;
  if( (now > lastU) && ((now - lastU) > SPEED_TIMEOUT)  )
  {   // now should never be < lastUsecs, but sometiems it is
      // I question if noInterupts works
     runSpeed = 0;
  }        
  interrupts(); 

  if( runSpeed != lastSpeed && dir == FW )
  {   
      lastSpeed = runSpeed;
      float dacval = (maxDACval/2) + (runSpeed/MAXSPEED * maxDACval/2);  
      if( dacval < 0 ) dacval = maxDACval/2;
      if( dacval > maxDACval) dacval = maxDACval;
      
      Serial.print(distance);
      Serial.print(",");
      Serial.println(dacval);    
      analogWrite(dacPin, dacval);
  }
  if(runSpeed != lastSpeed && dir == BW)
  {
      lastSpeed = runSpeed;
      float dacval = (maxDACval/2) - ((runSpeed/MAXSPEED) * (maxDACval/2)); 
      if( dacval < 0 ) dacval = maxDACval/2;
      if( dacval > maxDACval) dacval = 0;
      
      Serial.print(distance);
      Serial.print(",");
      Serial.println(dacval);    
      analogWrite(dacPin, dacval);
  }

}
