{{
*****************************************
* RCTIME v1.0                           *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *
* See end of file for terms of use.     *
*****************************************
}}

VAR

   long cogon, cog
   long RCStack[16]
   long RCTemp
   long Mode

PUB GetRaw(Pin,State,RCValueAddress)

  outa[Pin] := State                   'make I/O an output in the State you wish to measure... and then charge cap
  dira[Pin] := 1                               
  Pause1ms(1)                          'pause for 1mS to charge cap
  dira[Pin] := 0                       'make I/O an input
  RCTemp := cnt                        'grab clock tick counter value
  WAITPEQ(1-State,|< Pin,0)            'wait until pin goes into the opposite state you wish to measure; State: 1=discharge 0=charge
  RCTemp := cnt - RCTemp               'see how many clock cycles passed until desired State changed
  RCTemp := RCTemp - 1600              'offset adjustment (entry and exit clock cycles Note: this can vary slightly with code changes)
  RCTemp := RCTemp >> 4                'scale result (divide by 16) <<-number of clock cycles per itteration loop
  long [RCValueAddress] := RCTemp      'Write RCTemp to RCValue

PUB Pause1ms(Period)|ClkCycles 
{{Pause execution for Period (in units of 1 ms).}}

  ClkCycles := ((clkfreq / 1000 * Period) - 4296) #> 381     'Calculate 1 ms time unit
  waitcnt(ClkCycles + cnt)                                   'Wait for designated time              

DAT
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