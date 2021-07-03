# HeadFixedTreadmill
This repository contains desgins to build a head-fixed linear treadmill apparatus and to run related data analysis.

Treadmill setups are a popular approach for in vivo recordings that require head-fixation and have been used by several labs
for example: Royer et al. 2012, Bittner et al. 2015, Danielson et al. 2016. This repository contains designs of custom-machined parts 
for a simple treadmill and head-fixation apparatus, as well as Arduino and Matlab code for tracking the position of the mouse and administer rewards.

Assembly:

Grounding of animal for lick detection: We implant a gold ground pin soldered to about 1 mm of tungsten wire above the cerebellum.
 
To assemble, clamp gold pin in a helping hand alligator clamp. Insert tungsten wire into the shallow hole of the flat end of the pin. Solder and then slip the wire approximately 1 mm from the pin. Likewise, solder a female connector to a long piece of wire (long enough to connect the mouse’s implanted pin to the lick counter) to ground the mouse. Solder a wire to the lick spout and connect it to the appropriate port on the lick counter. Licks will be sensed when a grounded mouse contacts the lick port, closing the circuit.

We tape the RFID scanner to the bottom of the mouse platform. Upload the RFID interface code to the Arduino Uno. Connect the RFID to the Arduino Uno, connect the following pins with jumper cables:

[RF522 Pin	->    Arduino Uno Pin (Digital)]

SDA	 ->         10

SCK	 ->         13

MOSI	->        11

MISO	->        12

IRQ	  ->        Not Used

GND	  ->        GND

RST	  ->        9

3.3 V	->        3.3V


To connect the Arduino Uno to the NI breakout box, solder jumper cables so that they have a split in one end. In other ones, one end of the cable will have a single tip (plugged into Arduino), and the other will have two tips (plugged into NI breakout box). This will give use two copies of the RFID signals: one is recorded and used for data analysis and the other is used as input to the pump. Connect the following pins with jumper cables:

[Arduino Uno Pin (Digital) ->	NI Breakout Box (Digital)]

2	-> P0-6 and PFI-5

3 -> P0-5 and PFI-4

4	-> P0-4 and PFI-3

5	-> P0-3 and PFI-2

6 -> P0-2 and PFI-1


Upload the rotary encoder interface code to the Arduino Due. To connect the rotary encoder to the Arduino Due, connect the following pins with jumper cables:

[Encoder Pins ->	Arduino Due Pins (Digital)]

Pin 1 (GND) ->	GND

Pin 2 	-> Not used

Pin 3 (Chan A) ->	3

Pin 4 (Vcc)	-> 5V

Pin 5 (Chan B) ->	4


To connect the Arduino Due to the NI breakout box, connect the DAC1 pin and a GND pin on the Due to a BNC adapter cable (DAC1 to voltage and GND to GND). Connect the BNC adapter to a BNC analog input on the NI breakout box (we use port analog input 0, or AI0).

To connect the lick counter to the breakout box, plug a BNC adapter cable into the lick counter output. Plus the voltage line into the port0/line7 on the NI breakout box and the GND into one of the digital GND ports.

For the pump command, we use a BNC splitter to send the output to the water pump for reward administration as well as to an input on the NI breakout box to record the command. To connect the NI breakout box to the water pump, plug a BNC adapter into digital port 0/line 0 and GND. Plug the adapter into a splitter. Use a BNC cable to plug one line into analog input 1 (AI1) and use a BNC adapter to plug the other line into the pump. For this, plug the voltage line into pin 2 on the pump's serial port and the GND into pin 9 of the pump's serial port.
 
Make sure jumper cables are stably connected. We happened to have old jumper cables whose pins fit perfectly into the pump TTL port, but many jumper cables fell out too easily to be used.



Acknowledgements:

The rotary encoder interface that tracks the velocity of the mouse is based on code by Steven Sawtelle (Janelia Research Campus).
The head-fixation bar was adapted from designs by the Golshani and Aharoni labs (UCLA).
The data acquisition routines in Matlab were adapted from code written by the Sjulson and Batista-Brito Labs (Einstein). We thank
Ehsan Sabri, Eliezyer Fermino De Oliveira, Luke Sjulson and Renata Batista-Brito for their technical advice and assistance.
