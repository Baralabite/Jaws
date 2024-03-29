CON

  MAX_SPEED = 150
  ARM_SPEED = 75

var
  long hb_stack[20]              'stack space for auto refresh cog
  long leftmotor, rightmotor, armmotor            'raw pulsewidth holders
  byte leftp, rightp, armp, cog
  byte leftSpeed, rightSpeed, armSpeed
  long leftDirection, rightDirection, armDirection

pub Start(LeftPin, ArmPin, RightPin) 

  dira[LeftPin]~
  outa[LeftPin]~
  dira[RightPin]~
  outa[RightPin]~
  dira[armpin]~
  outa[armpin]~
    
    
  leftp  := leftpin      
  rightp := rightpin
  armp := armpin

  leftSpeed := 0
  leftDirection := string("Stopped")
  rightSpeed := 0
  rightDirection := string("Stopped")

  stop
  dira[leftp]~~
  outa[leftp]~
  dira[rightp]~~
  outa[rightp]~
  dira[armp]~~
  outa[armp]~
                                                           
  if not leftmotor          
    setleftmotor(1500)
  if not rightmotor         
    setrightmotor(1500)
  if not armmotor         
    setarmmotor(1500)
  if not cog            
    cog := cognew(RefreshCog, @hb_stack) + 1

  return cog - 1

PUB getLeftSpeed

  return leftSpeed

PUB getLeftDirection

  return leftDirection

PUB getRightSpeed

  return rightSpeed

PUB getRightDirection

  return rightDirection

PUB getArmDirection

  return armDirection

PUB getArmSpeed

  return armSpeed

'---[Movement]---

PUB SetArmUp(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  setarmmotor(1500+(speed*2))
  armSpeed := Speed
  armDirection := String("Up")

PUB SetArmDown(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  setarmmotor(1500-(Speed*2))
  armSpeed := speed
  armDirection := String("Down")

PUB ArmUp(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  setarmmotor(1500+(speed*2))
  armSpeed := speed
  armDirection := String("Stopped")
  Pause(Time)
  halt

PUB ArmDown(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  setarmmotor(1500-(Speed*2))
  armSpeed := Speed
  armDirection := String("Stopped")
  Pause(Time)
  Halt

PUB SafeArmDown | br  

  SetArmDown(ARM_SPEED)

  repeat
    repeat until br== 1
      br := INA[18]
    Halt
    waitcnt(clkfreq/10+cnt)
    br := INA[18]
    if br == 1
      Halt
      return
    else
      SetArmDown(ARM_SPEED)
    

  Halt 

PUB SafeArmUp | bl

  SetArmUp(ARM_SPEED)
  repeat
    repeat until bl == 1
      bl := INA[17]
    Halt
    waitcnt(clkfreq/10+cnt)
    bl := INA[17]
    if bl == 1
      Halt
      return  
    else
      SetArmUp(ARM_SPEED)
  ArmDown(ARM_SPEED, 500)
  Halt

PUB Forward(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Forward")
  rightSpeed := Speed
  rightDirection := string("Forward")
  setleftmotor(1500+(Speed*2))
  setrightmotor(1500+(Speed*2))
  Pause(Time)
  Halt

PUB SetForward(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Forward")
  rightSpeed := Speed
  rightDirection := string("Forward")
  setleftmotor(1500+(Speed*2))
  setrightmotor(1500+(Speed*2))

PUB ForwardVerbose(SpeedL, SpeedR, Time)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Forward")
  rightSpeed := SpeedR
  rightDirection := string("Forward")
  setleftmotor(1500+(SpeedL*2))
  setrightmotor(1500+(SpeedR*2))
  Pause(Time)
  Halt

PUB SetForwardVerbose(SpeedL, SpeedR)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Forward")
  rightSpeed := SpeedR
  rightDirection := string("Forward")
  setleftmotor(1500+(SpeedL*2))
  setrightmotor(1500+(SpeedR*2))

PUB Backward(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Backward")
  rightSpeed := Speed
  rightDirection := string("Backward")
  setleftmotor(1500-(Speed*2))
  setrightmotor(1500-(Speed*2))
  Pause(Time)
  Halt

PUB SetBackward(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Backward")
  rightSpeed := Speed
  rightDirection := string("Backward")
  setleftmotor(1500-(Speed*2))
  setrightmotor(1500-(Speed*2))

PUB BackwardVerbose(SpeedL, SpeedR, Time)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Backward")
  rightSpeed := SpeedR
  rightDirection := string("Backward")
  setleftmotor(1500-(SpeedL*2))
  setrightmotor(1500-(SpeedR*2))
  Pause(Time)
  Halt

PUB SetBackwardVerbose(SpeedL, SpeedR)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Backward")
  rightSpeed := SpeedR
  rightDirection := string("Backward")
  setleftmotor(1500-(SpeedL*2))
  setrightmotor(1500-(SpeedR*2))

PUB ForwardLeft(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Forward")
  setleftmotor(1500+Speed)
  Pause(Time)
  Halt     

PUB SetForwardLeft(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Forward")
  setleftmotor(1500+(Speed*2)) 

PUB BackwardLeft(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Backward")
  setleftmotor(1500-(Speed*2))
  Pause(Time)
  Halt

PUB SetBackwardLeft(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Backward")
  setleftmotor(1500-(Speed*2))

PUB ForwardRight(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  rightSpeed := Speed
  rightDirection := string("Forward")
  setrightmotor(1500+(Speed*2))
  Pause(Time)
  Halt

PUB SetForwardRight(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  rightSpeed := Speed
  rightDirection := string("Forward")
  setrightmotor(1500+(Speed*2))

PUB BackwardRight(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  rightSpeed := Speed
  rightDirection := string("Backward")
  setrightmotor(1500-(Speed*2))
  Pause(Time)
  Halt

PUB SetBackwardRight(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  rightSpeed := Speed
  rightDirection := string("Backward")
  setrightmotor(1500-(Speed*2))

PUB SpinLeft(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Backward")
  rightSpeed := Speed
  rightDirection := string("Forward")
  setleftmotor(1500-(Speed*2))
  setrightmotor(1500+(Speed*2))
  Pause(Time)
  Halt

PUB SetSpinLeft(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Backward")
  rightSpeed := Speed
  rightDirection := string("Forward")
  setleftmotor(1500-(Speed*2))
  setrightmotor(1500+(Speed*2))

PUB SpinRight(Speed, Time)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Forward")
  rightSpeed := Speed
  rightDirection := string("Backward")
  setleftmotor(1500+(Speed*2))
  setrightmotor(1500-(Speed*2))
  Pause(Time)
  Halt

PUB SetSpinRight(Speed)

  Speed #>= 0
  Speed <#= MAX_SPEED
  leftSpeed := Speed
  leftDirection := string("Forward")
  rightSpeed := Speed
  rightDirection := string("Backward")
  setleftmotor(1500+(Speed*2))
  setrightmotor(1500-(Speed*2))

PUB SpinLeftVerbose(SpeedL, SpeedR, Time)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Backward")
  rightSpeed := SpeedR
  rightDirection := string("Forward")
  setleftmotor(1500-(SpeedL*2))
  setrightmotor(1500+(SpeedR*2))
  Pause(Time)
  Halt

PUB SetSpinLeftVerbose(SpeedL, SpeedR)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Backward")
  rightSpeed := SpeedR
  rightDirection := string("Forward")
  setleftmotor(1500-(SpeedL*2))
  setrightmotor(1500+(SpeedR*2))

PUB SpinRightVerbose(SpeedL, SpeedR, Time)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Forward")
  rightSpeed := SpeedR
  rightDirection := string("Backward")
  setleftmotor(1500+(SpeedL*2))
  setrightmotor(1500-(SpeedR*2))
  Pause(Time)
  Halt

PUB SetSpinRightVerbose(SpeedL, SpeedR)

  SpeedL #>= 0
  SpeedL <#= MAX_SPEED
  SpeedR #>= 0
  SpeedR <#= MAX_SPEED
  leftSpeed := SpeedL
  leftDirection := string("Forward")
  rightSpeed := SpeedR
  rightDirection := string("Backward")
  setleftmotor(1500+(SpeedL*2))
  setrightmotor(1500-(SpeedR*2))

PUB Halt

  setleftmotor(1500)
  setrightmotor(1500)
  setarmmotor(1500)
  armSpeed := 0
  armDirection := String("Stopped")
  leftSpeed := 0
  leftDirection := string("Stopped")
  rightSpeed := 0
  rightDirection := string("Stopped")

'---[Util]---

PRI setleftmotor(Pulse1)

  pulse1 #>= 1000
  pulse1 <#= 2000

  leftmotor := ((pulse1 * (clkfreq / 1_000_000)) - 1200) #> 381

PRI setrightmotor(Pulse2)

  pulse2 #>= 1000          
  pulse2 <#= 2000

  rightmotor := ((pulse2 * (clkfreq / 1_000_000)) - 1200) #> 381

PRI setarmmotor(Pulse3)

  pulse3 #>= 1000
  pulse3 <#= 2000

  armmotor := ((pulse3 * (clkfreq / 1_000_000)) - 1200) #> 381 

PUB pulse_motors
    

  outa[leftp]~~                                               
  waitcnt(leftmotor + cnt)                                     
  outa[leftp]~
  outa[rightp]~~                              
  waitcnt(rightmotor + cnt)                                
  outa[rightp]~
  outa[armp]~~                              
  waitcnt(armmotor + cnt)                                
  outa[armp]~                                                                   
  waitcnt(clkfreq / 200 + cnt)      

pri Stop

  if cog
    cogstop(cog~ - 1)
    
PRI RefreshCog    

  dira[leftp]~~
  outa[leftp]~  
  dira[rightp]~~
  outa[rightp]~
  dira[armp]~~
  outa[armp]~ 
  repeat
    pulse_motors
    'waitcnt(clkfreq / 100 + cnt)

PRI Pause(ms)

  waitcnt(clkfreq/(1000/ms)+cnt)
                            