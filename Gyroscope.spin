{{

┌─────────────────────────────────────┬────────────────────────┬──────┬────────┐
│ L3G4200D_Example_Code.spin          │ (C)2011 Parallax, Inc. │ V1.0 │ Jul 25 │
├─────────────────────────────────────┴────────────────────────┴──────┴────────┤
│ Demonstrates X,Y,Z output to a serial terminal. Uses default (I²C) interface │
│ on the Gyroscope module.                                                     │
│ This program is for example purposes only for RAW data from the Gyroscope    │
│ Module. The calculations provided are for example only and should not be     │
│ relied on for accuracy. For details about calculating Gyroscope values and   │
│ other important information on functionality, please see the documents on our│
│ product page. Our Forums also have very useful information on this topic.    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
''modified by Dave Ratcliff 'ratronic' 4/6/12 added 1s delay to beginning of calibrate method, added integrated axis variables and display, changed baud rate
   ┌─────────────────┐                                                    ''also added 10ms delay to main loop
   │   L        INT2 ┣───   Data ready/FIFO interrupt
   │   3        INT1 ┣───   Programmable interrupt
   │   G         SDO ┣───   SPI serial data output -- I²C LSB of the device address (SA0)
   │   4 SDA/SDI/SDO ┣───   I²C serial data (SDA) -- SPI serial data input (SDI) -- 3-wire SPI data output (SDO)
   │   2         SCL ┣───   I²C & SPI clock
   │   0         CS  ┣───   I²C/SPI mode selection (defaulted to I²C) pull low for SPI mode
   │   0         VIN ┣───   2.7 - 6.5VDC (module is regulated to 2.5VDC)
   │   D         GND ┣──┐
   └─────────────────┘  

}}  

CON

  SDApin         = 24
  SCLpin         = 25     
    
  '****Registers****

  WRITE         = $D2
  READ          = $D3
  
  CTRL_REG1     = $20    'SUB $A0 
  CTRL_REG3     = $22
  CTRL_REG4     = $23
  STATUS_REG    = $27
  OUT_X_INC     = $A8


  x_idx = 0
  y_idx = 1
  z_idx = 2
    
VAR

long x, ix
long y, iy
long z, iz

long cx
long cy
long cz

long ff_x
long ff_y
long ff_z

long multiBYTE[3]

PUB Start

  Wrt_1B(CTRL_REG3, $08)                                'set up data ready signal
  Wrt_1B(CTRL_REG4, $80)                                'set up "block data update" mode (to avoid bad reads when the values would get updated while we are reading) 
  Wrt_1B(CTRL_REG1, $1F)                                'write a byte to control register one (enable all axis, 100Hz update rate)

  Calibrate

PUB Update

  WaitForDataReady 
  Read_MultiB(OUT_X_INC)

  x := x - cx          
  y := y - cy
  z := z - cz
  x := x / 114
  y := y / 114
  z := z / 114
  ix += x
  iy += y
  iz += z

PUB GetRelativeX

  return x

PUB GetRelativeY

  return y

PUB GetRelativeZ

  return Z

PUB GetX

  return ix

PUB GetY

  return iy

PUB GetZ

  return iz

PUB Flush

  ix := 0
  iy := 0
  iz := 0

PUB FlushX

  ix := 0

PUB FlushY

  iy := 0

PUB FlushZ

  iz := 0
  
PUB Calibrate

  waitcnt(clkfreq/2+cnt)                                  ''''added for physical delay
  
  cx := 0
  cy := 0
  cz := 0

  repeat 25
    WaitForDataReady
    Read_MultiB(OUT_X_INC)                              ' read the 3 axis values and accumulate
    cx += x
    cy += y
    cz += z

  cx /= 25                                              ' calculate the average
  cy /= 25
  cz /= 25

    
PUB WaitForDataReady | status
    repeat
      status := Read_1B(STATUS_REG)                     ' read the ZYXZDA bit of the status register (looping until the bit is on)
      if (status & $08) == $08
        quit
                        
PUB Wrt_1B(SUB1, data)

  ''Write single byte to Gyroscope.
  
      start_
      send(WRITE)                   'device address as write command
        'slave ACK
      send(SUB1)                    'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      send(data)                    'data you want to send
        'slave ACK
      stop
 
PUB Wrt_MultiB(SUB2, data, data2)

 ''Write multiple bytes to Gyroscope.

      start_
      send(WRITE)                   'device address as write command
        'slave ACK
      send(SUB2)                    'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      send(data)                    'data you want to send
        'slave ACK
      send(data2)                   'data you want to send
        'slave ACK
      stop

PUB Read_1B(SUB3) | rxd

 ''Read single byte from Gyroscope

      start_
      send(WRITE)                   'device address as write command
        'slave ACK
      send(SUB3)                    'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      stop
      start_                         'SR condition
      send(READ)                    'device address as read command
        'slave ACK
      rxd := receive(false)         'recieve the byte and put in variable rxd
      stop
  
     result := rxd

PUB Read_MultiB(SUB3) 

 ''Read multiple bytes from Gyroscope

     start_
      send(WRITE)                     'device address as write command
        'slave ACK
      send(SUB3)                       'SUB address = Register MSB 1 = reg address auto increment
        'slave ACK
      stop
      start_                           'SR condition
      send(READ)                      'device address as read command
        'slave ACK
      multiBYTE[x_idx] := (receive(true)) |  (receive(true)) << 8         'Receives high and low bytes of Raw data
      multiBYTE[y_idx] := (receive(true)) |  (receive(true)) << 8                                                                                 
      multiBYTE[z_idx] := (receive(true)) |  (receive(false)) << 8 
      stop
  
      x := ~~multiBYTE[x_idx]
      y := ~~multiBYTE[y_idx]
      z := ~~multiBYTE[z_idx]

PRI send(value)  ' I²C Send data - 4 Stack Longs 

  value := ((!value) >< 8)

  repeat 8
    dira[SDApin]       := value
    dira[SCLpin]       := false
    dira[SCLpin]       := true
    value >>= 1

  dira[SDApin]         := false
  dira[SCLpin]         := false
  result               := not(ina[SDApin])
  dira[SCLpin]         := true
  dira[SDApin]         := true

PRI receive(aknowledge) ' I²C receive data - 4 Stack Longs

  dira[SDApin]         := false

  repeat 8
    result <<= 1
    dira[SCLpin]       := false
    result             |= ina[SDApin]
    dira[SCLpin]       := true

  dira[SDApin]         := (aknowledge)
  dira[SCLpin]         := false
  dira[SCLpin]         := true
  dira[SDApin]         := true

PRI start_ ' 3 Stack Longs

  outa[SDApin]         := false
  outa[SCLpin]         := false
  dira[SDApin]         := true
  dira[SCLpin]         := true

PRI stop ' 3 Stack Longs

  dira[SCLpin]         := false
  dira[SDApin]         := false

{{                                                                                                                                 
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐                           
│                                                   TERMS OF USE: MIT License                                                  │   
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │   
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │   
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│   
│is furnished to do so, subject to the following conditions:                                                                   │   
│                                                                                                                              │   
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│   
│                                                                                                                              │   
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │   
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │   
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │   
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │   
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘   
}}                                                        