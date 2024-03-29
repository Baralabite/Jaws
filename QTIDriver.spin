VAR

   long RCTemp

PUB addQTI(PowerPin)

  DIRA[PowerPin]~~
  OUTA[PowerPin]~~
    
PUB getRaw(Pin)

  outa[Pin] := 1                  
  dira[Pin] := 1                               
  Pause1ms(1)                          
  dira[Pin] := 0                       
  RCTemp := cnt                        
  WAITPEQ(1-1,|< Pin,0)            
  RCTemp := cnt - RCTemp               
  RCTemp := RCTemp - 1600              
  RCTemp := RCTemp >> 4
  return RCTemp

PUB Pause1ms(Period)|ClkCycles 
{{Pause execution for Period (in units of 1 ms).}}

  ClkCycles := ((clkfreq / 1000 * Period) - 4296) #> 381    
  waitcnt(ClkCycles + cnt)         
