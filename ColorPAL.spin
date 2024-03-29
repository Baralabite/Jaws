{

  ColorPAL
  Version 1.1
  Author: George Collins
          www.trailofdestrurtion.com
          georgeecollins@yahoo.com

  This program uses the ColorPAL (Parallax Part # 28380) to detect
  red, green, or blue on a nearby surface.

             ┌────────────────┐
   PAL_PIN ──┤             _  │
   +5v     ──┤ ColorPAL   (_) │
   Gnd     ──┤                │
             └────────────────┘

  To get a good reading the ColorPAL needs to be as close ot the surface
  to be measured as possible.  Touching is best, one inch sort of works. 

  Set the constant PAL_PIN value to the pin number connected to the signal
  pin of the ColorPAL.  

  Revisions:
        1.1 Changed the baud from 7200 to 4800.  Fixed a bug in GetBlue
}



OBJ
  serial : "LightweightSerial"  ' Simple Serial, tested on v1.2 of that program 

VAR
  byte input[9] ' the PAL can return strings as long as 9 bytes
  byte redbuf[8] ' buffer of red input
  byte tbyte

{
  Init(pal_pin)
  
  pal_pin= Pin # of the pin connected the ColorPAL signal pin.
           Update the pin # based on your hardware set up.   

  Sets the ColorPAL to direct mode to recieve input.
  You must call this before sending any message to the ColorPAL. 
 
}

PUB Init(pal_pin) | loop, baud

 
  outa[pal_pin]:=0 ' set pin to low
  dira[pal_pin]:=0 ' direction input
  loop:=0
  baud:=7200
  'reset the ColorPAL and put it in direct mode
  repeat while (loop==0)
    if (ina[pal_pin]<>0)
      dira[pal_pin]:=1 ' output
      outa[pal_pin]:=0 ' set pin to low
      waitcnt(cnt+80*CLKFREQ/(1000)) ' wait 80 ms
      dira[pal_pin]:=1
      waitcnt(cnt+10*CLKFREQ/(1000))
      loop:=1
      
  serial.init(pal_pin, pal_pin, baud)

  LEDColor(255, 255, 255)

PUB Stop

  serial.finalize

PUB Restart(pal_pin)

  serial.finalize
  Init(pal_pin)

PUB LEDColor(r, g, b)

  ' clamp each color to a one byte range
  r := 0 #> r <# $FF
  g := 0 #> g <# $FF
  b := 0 #> b <# $FF
  
  serial.str(STRING("= r"))

  ' convert r, g, and b into two digit hexadecimal strings  
  serial.tx(HexChar[r/16])
  serial.tx(HexChar[r//16])
  serial.tx(HexChar[g/16])
  serial.tx(HexChar[g//16])
  serial.tx(HexChar[b/16])
  serial.tx(HexChar[b//16])
   
  serial.str(STRING(" !")) ' tell the ColorPAL to execute

{
  GetRed

  Get the amount of light reflected by a red light which represents
  how red the surface in front of the detecter is.
  GetGreen, GetBlue work the same way.  

}
PUB GetRed | loop, ambient, red
  serial.str(string("= X s !"))
  ' read a 3 digit hexadecimal value
  repeat loop from 0 to 2
    input[loop]:=serial.rx
  ambient:=HexCharToDec(input[0])*$FF+HexCharToDec(input[1])*$F+HexCharToDec(input[2])

  serial.str(string("= R s !"))
  repeat loop from 0 to 2
    input[loop]:=serial.rx
    redbuf[loop]:=input[loop]
    
  red:=HexCharToDec(input[0])*$FF+HexCharToDec(input[1])*$F+HexCharToDec(input[2])

  if (red-ambient>0)  
    return red-ambient
  else
    return 0 

' GetGreen - like GetRed

PUB GetGreen | loop, ambient, green
  serial.str(string("= X s !"))
  repeat loop from 0 to 2
    input[loop]:=serial.rx
  ambient:=HexCharToDec(input[0])*$FF+HexCharToDec(input[1])*$F+HexCharToDec(input[2])

  serial.str(string("= G s !"))
  repeat loop from 0 to 2
    input[loop]:=serial.rx
  green:=HexCharToDec(input[0])*$FF+HexCharToDec(input[1])*$F+HexCharToDec(input[2])

  if (green-ambient>0)
    return green-ambient
  else
    return 0 

' GetBlue - like GetRed

PUB GetBlue | loop, ambient, blue 
  serial.str(string("= X s !"))
  repeat loop from 0 to 2
    input[loop]:=serial.rx
  ambient:=HexCharToDec(input[0])*$FF+HexCharToDec(input[1])*$F+HexCharToDec(input[2])

  serial.str(string("= B s !"))
  repeat loop from 0 to 2
    input[loop]:=serial.rx
  blue:=HexCharToDec(input[0])*$FF+HexCharToDec(input[1])*$F+HexCharToDec(input[2])

  if (blue-ambient>0)
    return blue-ambient
  else
    return 0

{
  HexCharToDec
  The ColorPal returns values as character strings representing
  hexadecimal numbers.  You need to convert each character to a
  decimal number from 0-15
}  

PUB HexCharToDec(c) | loop

  repeat loop from 0 to 15  
    if (HexChar[loop]==c)
      return loop
    
  return 0  ' this is a char that is not within 0..F
 
DAT  
  HexChar byte "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"      


{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}


   