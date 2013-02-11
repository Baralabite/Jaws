CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
          
  DEBUG = FALSE
  
  FAST_SPEED = 120
  MED_SPEED = 90
  LOW_SPEED = 80
  END_TILE_BLOCK_DIST = 65 'cm

  BRIDGE_THRESHOLD = 2000

{

TODO:

  Improve Speedbumps algorithm
  Fix Issue with Demounting Bridge/Seesaw
  Fix Watertower

  Improve Scanning Algorithm
  Improve Offline Algorithm

}

VAR

  long logicspeed
  long location

  byte DebugCogID

  long dbgQTIL, dbgQTIR, dbgQTIM, dbgQTIOL, dbgQTIOR, dbgLR, dbgLG, dbgLB
  long dbgRR, dbgRG, dbgRB, dbgPM, dbgPR, dbgLOC, dbgHEAD, dbgCU, dbgMTRLS
  long dbgMTRLD, dbgMTRAS, dbgMTRAD, dbgMTRRS, dbgMTRRD, dbgSL, dbgSD, dbgS1
  long dbgS2, dbgS3

  long stack[100]

  word Speed

  long timesLostLine, inGreenTile, cornersTurned, timeFromLastGreenTurn, lastTurnDirection
  byte offcounter

  long StartingAngle, lowestDist, lowestDistAngle

  long highestGyroValue

  byte ForceArmOpen
  long n, hn, humpCounter, c, onApex

OBJ

  Serial        : "Serial"
  Sensor        : "Sensors"
  Motor         : "HB"
  LCD           : "LCD"
  PC            : "PC"
  Profiler[2]   : "Profiler"
  Claw          : "Claw"
  Cog           : "CogManager"
  Alerter       : "Alerter"

PUB Main

  Alerter.Warning
  Start
  Loop
  Stop

PRI ArmLoop | override

  'if override is set to true, then it ignores the gyro readings

  Claw.Start

  repeat
    if IsSpeedBumps or IsWaterTower
      override := true
      Claw.Open
    else
      override := false

    if override==false
      if Sensor.getRelY > 30
        Claw.Open
      elseif Sensor.getRelY < -30 and not IsSpeedBumps and not IsWaterTower
        Claw.Close
      
    

 { repeat
    if Sensor.getFeeler == 0 and not IsSpeedBumps
      Sensor.SetNormalCalibration
      {Claw.Start
      waitcnt(clkfreq/4+cnt)
      Claw.Open
      waitcnt(clkfreq/4+cnt)
      Claw.Stop}    

    if Sensor.getFeeler > 0 and not IsSpeedBumps
      waitcnt(clkfreq+cnt)
      if Sensor.getFeeler > 0        
        Sensor.Set3DCalibration
      {Claw.Start
      waitcnt(clkfreq/4+cnt)
      Claw.Close
      waitcnt(clkfreq/4+cnt)
      Claw.Stop }
    {if isLineFollowing or isS*peedBumps
      if sensor.getRelY > 40
        Sensor.SetSpeedBumpsCalibration
        Claw.Start
        waitcnt(clkfreq/4+cnt)
        Claw.Close
        waitcnt(clkfreq/4+cnt)
        Claw.Stop
      elseif Sensor.getRelY < -40
        Sensor.setNormalCalibration
        waitcnt(clkfreq/3+cnt)
        Claw.Start
        waitcnt(clkfreq/4+cnt)
        Claw.Open
        waitcnt(clkfreq/4+cnt)
        Claw.Stop}}

PRI UpdateLCD

  LCD.ClearScreen
  LCD.FirstLine

  LCD.Str(location)

{  LCD.Dec(Sensor.getLeftQTI)
  LCD.Str(String(", "))
  LCD.Dec(sensor.getMiddleQTI)
  LCD.Str(String(", "))         
  LCD.Dec(Sensor.getRightQTI)}

  LCD.CR
  LCD.Dec(Sensor.getLeftQTIColor)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getMiddleQTIColor)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getRightQTIColor)

  LCD.CR

  LCD.Dec(Sensor.getMiddleMM)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getFeelerRaw)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getFeeler)
  
  LCD.CR
  'LCD.Dec(sensor.getLeftCalibration)
  'LCD.Str(string(", "))
  LCD.Dec(Sensor.getLeftQTI)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getMiddleQTI)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getRightQTI)

  LCD.CR

  LCD.Dec(Sensor.getLeftRed)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getLeftGreen)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getLeftBlue)
  LCD.Str(string(", "))
  LCD.Dec(Sensor.getRightRed)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getRightGreen)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getRightBlue)

  'if sensor.getRelY > 30
  '  LCD.Beep
  'elseif Sensor.getRelY < -30
  '  LCD.Beep

  {LCD.Dec(Sensor.getY)
  LCD.Str(String(", "))
  LCD.Dec(Sensor.getHighestY)
  LCD.Str(string(", "))
  LCD.Dec(Sensor.getLowestY)} 
    
PUB Start

  Sensor.Start(4, 8, 9, 10, 11, 12, 5)
  'Claw.Start  
  SetSpeedFast
  Motor.Start(1, 2, 3)

  'if Sensor.getArmButton==1
  ''  Motor.SafeArmUp
  'else
  '  Motor.SafeArmDown

  DebugCogID := cognew(DebugLoop, @stack[0])
  cognew(ArmLoop, @stack[51])
  
  ToLineFollowing

PUB Stop

  Claw.Close
  Motor.Halt
  repeat

PUB Loop | l, m, r

  Alerter.AllClear

  repeat
    l := Sensor.getLeftQTIColor
    m := Sensor.getMiddleQTIColor
    r := Sensor.getRightQTIColor

    if timeFromLastGreenTurn > 0
      timeFromLastGreenTurn++
      
      
    if sensor.getMiddleCM =< 11 and not Sensor.getMiddleCM==0
      Motor.Halt
      waitcnt(clkfreq/10+cnt)
      if sensor.getMiddleCM =< 11 and not Sensor.getMiddleCM==0    
        ToCloseObject

    if Sensor.getFeeler==0
      onApex := 0

    if Sensor.getFeeler > 0 and Sensor.getMiddleQTIColor==1
      'Motor.ForwardVerbose(Speed-20, Speed, 30)
      onApex++
      if onApex==500
        location := String("Bridge")
        Motor.ForwardVerbose(Speed-20, Speed, 200)
        Sensor.set3DCalibration
        repeat until Sensor.getFeeler==0
          FollowLine
        repeat 1000
          FollowLine
        Sensor.setNormalCalibration
        onApex := 0
        
      'Sensor.set3DCalibration
      'repeat until Sensor.getFeeler==0
      '  FollowLine
      Sensor.setNormalCalibration
    if Sensor.isOffline
      ToOffline
    elseif not isLineFollowing and m==1
      ToLineFollowing
    elseif l==1 and m==1 and r==1 and not Sensor.getFeeler==-1
      'Motor.Halt
      'waitcnt(clkfreq/10+cnt)
      if Sensor.getLeftCPALColor==1  
        ToGreenCornerLeft
      elseif Sensor.getRightCPALColor==1
        ToGreenCornerRight
    {elseif Sensor.getMiddleQTI > BRIDGE_THRESHOLD
      Motor.Halt
      waitcnt(clkfreq/5+cnt)
      repeat 4
        if Sensor.getLeftCPALColor==1  
          ToGreenCornerLeft
          quit
        elseif Sensor.getRightCPALColor==1
          ToGreenCornerRight
          quit
        waitcnt(clkfreq/5+cnt)
      if Sensor.getMiddleQTI > BRIDGE_THRESHOLD
        ToBridge
      'Motor.Halt }
    if Sensor.getRelY < -150
      Motor.Halt
      waitcnt(clkfreq/2+cnt) 

    if isLineFollowing
      FollowLine

'-----{ Location }-----'

PRI ToLineFollowing

  location := @LINE_FOLLOWING
  SetSpeedFast

PRI ToOffline

  Alerter.Error

  if isLineFollowing
    location := @OFF_LINE
  SetSpeedFast

  Motor.Forward(MED_SPEED, 100)

  if Sensor.getMiddleCM < END_TILE_BLOCK_DIST
    Motor.Forward(FAST_SPEED, 500)
    repeat 5
      if Sensor.getLeftCPALColor == 1 and Sensor.getRightCPALColor == 1
        ToChemSpill
        return
      waitcnt(clkfreq/8+cnt)
      
    timesLostLine++
    Motor.halt
    repeat until Sensor.getMiddleQTIColor==1
      Motor.Backward(100, 50)
    toLineFollowing
          
  else
    timesLostLine++
    Motor.halt
    repeat until Sensor.getMiddleQTIColor==1
      Motor.Backward(100, 50)
    Motor.Backward(100, 200)
    if isOffline
      toLineFollowing

  Alerter.AllClear
  
  offcounter++


PRI ToWaterTower | startDistFromTower, endHeading, distFromTowerToUphold, prevDist, iter, fin

  location := @WATER_TOWER
  n := 9001

  Motor.Halt

  startDistFromTower := 70
  distFromTowerToUphold := 65

  repeat until Sensor.getMiddleMM > startDistFromTower
    Motor.BackwardVerbose(LOW_SPEED, LOW_SPEED, 10)
  {repeat until Sensor.getMiddleMM == StartDistFromTower
    if Sensor.getMiddleMM < StartDistFromTower
      Motor.Backward(LOW_SPEED, 1)
    else
      Motor.Forward(LOW_SPEED, 1)

  waitcnt(clkfreq/5+cnt)

  repeat until Sensor.getMiddleMM == StartDistFromTower
    if Sensor.getMiddleMM < StartDistFromTower
      Motor.Backward(LOW_SPEED, 1)
    else
      Motor.Forward(LOW_SPEED, 1)}

  repeat until Sensor.getRightMM < distFromTowerToUphold
    if sensor.getRightMM < n and not Sensor.getRightMM==0
      n := Sensor.getRightMM

    elseif Sensor.getRightMM > n+10 and not n==9001 and n < 70
      if Sensor.getRightMM > 100
        repeat until Sensor.getRightMM < n+5
          Motor.SpinRight(LOW_SPEED, 10)
      prevDist := Sensor.getRightMM
      quit
      
    Motor.SpinLeft(FAST_SPEED, 50)

  Motor.Forward(MED_SPEED, 200)

  iter := 50
  
  repeat 100
    if Sensor.getRightMM > distFromTowerToUphold and Sensor.getRightMM < distFromTowerToUphold + 20 
      Motor.SpinRight(MED_SPEED, 10)
    elseif Sensor.getRightMM > distFromTowerToUphold + 20
      'Lost!
      fin := 0
      repeat 50
        if Sensor.getRightMM < distFromTowerToUphold + 10
          fin := 1
          quit  
        Motor.Forward(MED_SPEED, 10)
                                                   
      if fin==1
        next
      
      repeat 100
        Motor.SpinRight(MED_SPEED, 10)
        if Sensor.getRightMM < 75
          fin := 1
          quit

      if fin==1
        next      

      repeat 200
        Motor.SpinLeft(MED_SPEED, 10)
        if Sensor.getRightMM < 75
          fin := 1
          quit

      if fin==1
        next

      location := String("Really, Really lost")

      repeat until Sensor.getMiddleMM < 200
        Motor.SpinRight(MED_SPEED, 10)

      repeat until Sensor.getMiddleMM > 500
        Motor.SpinRight(MED_SPEED, 10)

      repeat until Sensor.getMiddleMM < 300
        Motor.SpinRight(MED_SPEED, 10)

      location := String("Found!")

      repeat until Sensor.getArmButton==1
        Motor.ForwardVerbose(MED_SPEED, MED_SPEED+20, 10)

      location := String("Water Tower!")
      
      repeat
        
      'Really, REALLY Lost Now D:
        
      repeat until sensor.getRightMM < distFromTowerToUphold + 10
        Motor.Backward(LOW_SPEED, 10)
        waitcnt(clkfreq/5+cnt)
      
    else
      Motor.Forward(LOW_SPEED, 10)
    prevDist := Sensor.getRightMM

  location := String("Water Tower 2")
    
  repeat until Sensor.getMiddleQTIColor==1
    if Sensor.getRightMM > distFromTowerToUphold and Sensor.getRightMM < distFromTowerToUphold + 20 
      Motor.SpinRight(LOW_SPEED, 10)
    elseif Sensor.getRightMM > distFromTowerToUphold + 20
      'Lost!
      Motor.Forward(LOW_SPEED, 10)
    else
      Motor.Forward(LOW_SPEED, 10)
    prevDist := Sensor.getRightMM

  SetSpeedMedium
    
  repeat 5000
    FollowLineLeft

  return

  'rel: 10, 10, 100% -changed code at 6
    

  {
    if Sensor.getMiddleMM > StartDistFromTower - 5 and Sensor.getMiddleMM < StartDistFromTower + 5
      waitcnt(clkfreq/5+cnt)
      if Sensor.getMiddleMM > StartDistFromTower - 5 and Sensor.getMiddleMM < StartDistFromTower + 5
        quit
    elseif Sensor.getMiddleMM < StartDistFromTower
      Motor.Backward(MED_SPEED, 10)
    else
      Motor.Forward(MED_SPEED, 10)}

  repeat 
  
  repeat

  'Old Code'

  Motor.Backward(MED_SPEED, 300)

  startDistFromTower := 90
  distFromTowerToUphold := 50

  repeat until Sensor.getMiddleMM > startDistFromTower
    Motor.Backward(MED_SPEED, 10)
  repeat until Sensor.getMiddleMM == startDistFromTower
    if Sensor.getMiddleMM > startDistFromTower
      Motor.Forward(MED_SPEED, 10)
    elseif Sensor.getMiddleMM < startDistFromTower
      Motor.Backward(MED_SPEED, 10)

  repeat 4
    repeat
      if Sensor.getRightMM < distFromTowerToUphold + 10
        quit
      Motor.SpinLeft(MED_SPEED, 10)
    waitcnt(clkfreq/8+cnt)
  Motor.SpinLeft(MED_SPEED, 100)

  repeat until Sensor.getMiddleQTIcolor==0
    if Sensor.getRightMM > distFromTowerToUphold and Sensor.getRightMM < distFromTowerToUphold + 20 
      Motor.SpinRight(FAST_SPEED, 10)
    elseif Sensor.getRightMM > distFromTowerToUphold + 20
      repeat until Sensor.getRightMM < distFromTowerToUphold + 3
        Motor.SpinLeft(FAST_SPEED, 30)
        Motor.Forward(FAST_SPEED, 20)    
    else
      Motor.Forward(FAST_SPEED, 10)
    prevDist := Sensor.getRightMM

  repeat 50
    if Sensor.getRightMM > distFromTowerToUphold and Sensor.getRightMM < distFromTowerToUphold + 20 
      Motor.SpinRight(FAST_SPEED, 10)
    elseif Sensor.getRightMM > distFromTowerToUphold + 20
      repeat until Sensor.getRightMM < distFromTowerToUphold + 3
        Motor.SpinLeft(FAST_SPEED, 30)
        Motor.Forward(FAST_SPEED, 20)    
    else
      Motor.Forward(FAST_SPEED, 10)
    prevDist := Sensor.getRightMM

  repeat
    if Sensor.getMiddleQTIColor==1
      Motor.Halt
      waitcnt(clkfreq/10+cnt)
      if Sensor.getMiddleQTIColor==1
        quit
  
    if Sensor.getRightMM > distFromTowerToUphold and Sensor.getRightMM < distFromTowerToUphold + 20 
      Motor.SpinRight(MED_SPEED, 10)
    elseif Sensor.getRightMM > distFromTowerToUphold + 20
      repeat until Sensor.getRightMM < distFromTowerToUphold + 3
        Motor.SpinLeft(MED_SPEED, 30)
        Motor.Forward(MED_SPEED, 20)    
    else
      Motor.Forward(MED_SPEED, 10)
    prevDist := Sensor.getRightMM

  'Motor.Forward(FAST_SPEED, 200)

  SetSpeedMedium
  repeat 10000
    FollowLineLeft
           

  SetSpeedFast
  ToLineFollowing

PRI ToGreenCornerLeft | oppCrn

  location := @GREEN_LEFT

  if lastTurnDirection==2
    oppCrn := True
  else
    oppCrn := False

  CornerLeft

  lastTurnDirection := 1

  UpdateInGreenTile
  CheckForGridlock(oppCrn)
 
  timeFromLastGreenTurn := 1 

  cornersTurned++

PRI ToGreenCornerRight

  location := @GREEN_RIGHT

  CornerRight

  lastTurnDirection := 2

  UpdateInGreenTile
  timeFromLastGreenTurn := 1 

  cornersTurned++

PRI ToCloseObject

  location := @CLOSE_OBJECT
  SetSpeedSlow

  repeat 500
    if INA[16] == 1
      ToWaterTower
    elseif Sensor.getMiddleCM > 11
      ToLineFollowing
      return    
    FollowLine
  if not Sensor.getFeeler == -1
    ToSpeedBumps
  ToLineFollowing
  return

PRI ToBridge

  location := @BRIDGE
  
  'Motor.ForwardVerbose(MED_SPEED, MED_SPEED+80, 300)

  Sensor.setSpeedbumpsCalibration
  Speed := 150

  repeat
    if Sensor.getMiddleQTI < 1500
      waitcnt(clkfreq/5+cnt)
      if Sensor.getMiddleQTI < 1500
        quit
    'Motor.Halt
    'waitcnt(clkfreq/5+cnt)
    FollowLine
    'waitcnt(clkfreq/5+cnt)

  repeat 1000
    FollowLine            

  Sensor.setNormalCalibration

  repeat 100
    FollowLine
    
  ToLineFollowing

PRI ToSpeedBumps | onHump, x

  speed := 50

  Sensor.SetSpeedBumpsCalibration

  location := @SPEED_BUMPS

  repeat 100
    'Mtr.Forward(MIN_SPEED, 5)
    FollowLine
    if Sensor.getArmButton==1
      Motor.Halt
      waitcnt(clkfreq/10+cnt)
      if Sensor.getArmbutton == 1
        Sensor.setNormalCalibration
        ToWaterTower
        ToLineFollowing
        return

    if Sensor.getFeelerButton==1 and onHump==0
      waitcnt(clkfreq/10+cnt)
      if Sensor.getFeelerButton==1 and onHump==0      
        humpCounter++
        onHump := 1
    elseif Sensor.getFeelerButton==0
      waitcnt(clkfreq/10+cnt)
      if Sensor.getFeelerButton==0
        onHump := 0

    if humpCounter == 4
      humpCounter := 0
      repeat 2000
        FollowLine
      Motor.Halt
      quit

  SetSpeedMedium

  repeat
    'Mtr.Forward(MIN_SPEED, 5)
    FollowLine
    if Sensor.getArmButton==1
      Motor.Halt
      waitcnt(clkfreq/10+cnt)
      if Sensor.getArmbutton == 1
        Sensor.setNormalCalibration
        ToWaterTower
        ToLineFollowing
        return

    if Sensor.getFeelerButton==1 and onHump==0
      waitcnt(clkfreq/10+cnt)
      if Sensor.getFeelerButton==1 and onHump==0      
        humpCounter++
        onHump := 1
    elseif Sensor.getFeelerButton==0
      waitcnt(clkfreq/10+cnt)
      if Sensor.getFeelerButton==0
        onHump := 0

    if humpCounter == 4
      humpCounter := 0
      repeat 2000
        FollowLine
      Motor.Halt
      quit

  Sensor.SetNormalCalibration
  ToLineFollowing

PRI ToGridlock | x, a

  location := @GRIDLOCK
  SetSpeedMedium
  Motor.Halt

  timeFromLastGreenTurn := 9001

  repeat 2000
    FollowLine
            
  repeat x from 0 to 2
    repeat until Sensor.getLeftQTICOlor==1 and Sensor.getMiddleQTIColor==1 and Sensor.getRightQTIColor==1
      FollowLine
      timeFromLastGreenTurn := x
    repeat until Sensor.getLeftQTICOlor==0 and Sensor.getRightQTIColor==0 and Sensor.getMiddleQTIColor==1
      FollowLineThroughIntersection
      
      timeFromLastGreenTurn := x
      offcounter++ 

  x := false

  'Precondition: Robot is through 2 of the line crossings, but with the avaliability to
  'have only crossed one.
  'Idea is to get robot just after the 3rd turn in the course.

  SetSpeedMedium
  
  repeat
    if Sensor.getLeftQTIColor==1 and Sensor.getRightQTIColor==1 and sensor.getMiddleQTIColor==1
      Motor.Halt
      waitcnt(clkfreq/2+cnt)
      repeat until Sensor.getLeftQTIColor==1 or Sensor.getRightQTIColor==1
        Motor.Backward(LOW_SPEED, 10)
      if Sensor.getRightCPALCOlor==1
        CornerRight
        quit
      else
        Motor.Forward(SPEED, 500)

    elseif Sensor.getLeftQTIColor==0 and Sensor.getRightQTIColor==0 and Sensor.getMiddleQTIColor==0
      Motor.Halt
      waitcnt(clkfreq/5+cnt)
      if Sensor.getLeftQTIColor==0 and Sensor.getRightQTIColor==0 and Sensor.getMiddleQTIColor==0 
        repeat until Sensor.getMiddleQTIColor==1 and Sensor.getLeftQTIColor==1 and Sensor.getRightQTIColor==1
          Motor.Backward(SPEED, 10)      
    else
      FollowLine 

  'Precondition: Robot is just after 3rd (right) turn in the Gridlock of the course.

  x := false

  repeat until Sensor.getLeftCPALCOlor==1 and Sensor.getLeftQTICOlor==1 and Sensor.getMiddleQTIColor==1 and Sensor.getRightQTIColor==1 
    FollowLine

  CornerLeft

  repeat 300
    FollowLine

  inGreenTile := 0
  timeFromLastGreenTurn := 0
  ToLineFollowing

PRI ToChemSpill

  location := @CHEM_SPILL
  Motor.Halt
  Sensor.StopFastLoopCog
  startingAngle := Sensor.getDegrees
  Claw.Start
  Claw.Open

  ToFindingCan
  ToLiftingCan
  ToFindingBlock
  ToPlacingCan
  ToFinished
  REpeat

PRI ToFindingCan

  location := @FINDING_CAN
  
  ScanCan
  DriveToCan
  repeat lowestDist/10
    Motor.Backward(FAST_SPEED, 50)

  Motor.SafeArmUp

  Claw.HalfOpen

  Motor.Backward(MED_SPEED, 600)

  Claw.Close

  Motor.SafeArmDown

  Claw.Open

  repeat until sensor.getMiddleMM < 30 or Sensor.getArmButton==1
    Motor.Forward(MED_SPEED, 10)

  Claw.Close

PRI ToLiftingCan

  location := @LIFTING_CAN

  Motor.SafeArmUp

PRI ToFindingBlock

  location := @FINDING_BLOCK

  ScanBlock

  repeat
    waitcnt(clkfreq+cnt)
    repeat until sensor.getMiddleMM > lowestDist + 50
      Motor.SpinRight(LOW_SPEED, 10)
    waitcnt(clkfreq+cnt)
     
    repeat until Sensor.getMiddleMM < lowestDist + 50
      Motor.SpinLeft(LOW_SPEED, 10)
     
    waitcnt(clkfreq+cnt)
     
    Motor.Forward(MED_SPEED, 500)

    if Sensor.getMiddleMM < 75 or Sensor.getArmButton==1
      Claw.Open
      Motor.Backward(MED_SPEED, 500)
    
  repeat
    if Sensor.getMiddleCM < 5
      waitcnt(clkfreq/10+cnt)
      if Sensor.getMiddleCM< 5
        quit
    if Sensor.getMiddleMM > lowestDist + 75
      Motor.Backward(MED_SPEED, 300)
      ScanBlock
    Motor.ForwardVerbose(MED_SPEED, MED_SPEED+25, 10) 

PRI ToPlacingCan

  location := @PLACING_CAN

  'Motor.Forward(MED_SPEED, 300)
  Claw.HalfOpen
  waitcnt(clkfreq/2+cnt)
  claw.open

PRI ToFinished

  location := @FINISHED
  repeat lowestDist/10
    Motor.Backward(Fast_SPEED, 75)
  Claw.Close
  Motor.SafeArmDown
  Claw.Stop
  Stop

'-----{ Is at Location }-----'

PRI IsLineFollowing

  return strcomp(location, @LINE_FOLLOWING)

PRI IsOffline

  return strcomp(location, @OFF_LINE)

PRI IsCloseObject

  return strcomp(location, @CLOSE_OBJECT)

PRI IsWaterTower

  return strcomp(location, @WATER_TOWER)

PRI IsGreenCornerLeft

  return strcomp(location, @GREEN_LEFT)

PRI IsGreenCornerRight

  return strcomp(location, @GREEN_RIGHT)

PRI IsBridge

  return strcomp(location, @BRIDGE)

PRI IsSpeedBumps

  return strcomp(location, @SPEED_BUMPS)

PRI IsGridlock

  return strcomp(location, @GRIDLOCK)

PRI IsChemSpill

  return strcomp(location, @CHEM_SPILL)

PRI IsFindingCan

  return strcomp(location, @FINDING_CAN)

PRI IsLiftingCan

  return strcomp(location, @LIFTING_CAN)

PRI IsFindingBlock

  return strcomp(location, @FINDING_BLOCK)

PRI IsPlacingCan

  return strcomp(location, @PLACING_CAN)

PRI IsFinished

  return strcomp(location, @FINISHED)

'-----{ Predefined }-----'

PRI CheckForGridlock(oppCrn)

  if timeFromLastGreenTurn > 50 and timeFromLastGreenTurn < 6000 and not timeFromLastGreenTurn==0 and inGreenTile==0 and oppCrn==true
    ToGridlock
    timeFromLastGreenTurn := 9001
  'else
  '  timeFromLastGreenTurn := 1

PRI CornerLeft

  SetSpeedFast
  
  repeat until Sensor.getLeftQTIColor==0 and Sensor.getMiddleQTIColor==1 and sensor.getRightQTIColor==0
    FollowLineLeft
    if Sensor.isOffline
      ToOffline
      Motor.Backward(FAST_SPEED, 100)

  repeat 500
    FollowLine
    if Sensor.isOffline
      ToOffline
      Motor.Backward(FAST_SPEED, 100) 

  lastTurnDirection := 1
      
PRI CornerRight

  SetSpeedFast

  repeat until Sensor.getLeftQTIColor==0 and Sensor.getMiddleQTIColor==1 and sensor.getRightQTIColor==0
    FollowLineRight
    if Sensor.isOffline
      ToOffline
      Motor.Backward(FAST_SPEED, 100)

  repeat 500
    FollowLine
    if Sensor.isOffline
      ToOffline
      Motor.Backward(FAST_SPEED, 100)

  lastTurnDirection := 2

PRI FollowLine | l, r

  l := Sensor.getLeftQTIColor
  r := Sensor.getRightQTIColor

  if l
    Motor.SetSpinLeft(Speed)
  elseif r
    Motor.SetSpinRight(Speed)
  else
    Motor.SetForward(Speed)

PRI FollowLineThroughIntersection | l, r

  l := Sensor.getLeftQTIColor
  r := Sensor.getRightQTIColor

  if l and r
    Motor.SetForward(Speed)  
  elseif l
    Motor.SetSpinLeft(Speed)
  elseif r
    Motor.SetSpinRight(Speed)
  else
    Motor.SetForward(Speed)

PRI FollowLineLeft | l, r

  l := Sensor.getLeftQTIColor
  r := Sensor.getRightQTIColor

  if l
    Motor.SetSpinLeft(Speed)
  elseif r
    Motor.Forward(Speed, 25)
    Motor.SetSpinRight(Speed)
  else
    Motor.SetForward(Speed)

PRI FollowLineRight | l, r

  l := Sensor.getLeftQTIColor
  r := Sensor.getRightQTIColor

  if r
    Motor.SetSpinRight(Speed)
  elseif l
    Motor.Forward(Speed, 25)
    Motor.SetSpinLeft(Speed)
  else
    Motor.SetForward(Speed)

PRI TurnLeftUnit(Unit) | endunit

  endunit := Sensor.getDegrees + Unit

  repeat until sensor.getDegrees > endunit - 3 and sensor.getDegrees < endunit + 3
    if sensor.getDegrees < endunit
      Motor.SpinLeft(FAST_SPEED, 10)
    elseif sensor.getDegrees > endunit
      Motor.SpinRight(FAST_SPEED, 10)

PRI TurnToHeading(Heading) | endunit

  endunit := heading

  repeat until sensor.getDegrees == endunit
    if sensor.getDegrees < endunit
      Motor.SpinLeft(FAST_SPEED, 10)
    elseif sensor.getDegrees > endunit
      Motor.SpinRight(FAST_SPEED, 10)

PRI ScanCan | omega

  omega :=  StartingAngle - 110

  TurnToHeading(startingAngle+110)

  lowestDist := 5000
  lowestDistAngle := 0
  
  repeat until sensor.getDegrees < omega
    Motor.SpinRight(FAST_SPEED, 10)
    if Sensor.GetMiddleMM < lowestDist
      waitcnt(clkfreq/50+cnt)
      if Sensor.GetMiddleMM < lowestDist
        lowestDist := Sensor.GetMiddleMM
        lowestDistAngle := Sensor.getDegrees
      if Sensor.getMiddleMM < 50
        return
  
  TurnToHeadingAndDistance(lowestDistAngle, lowestDist)

PRI DriveToCan | lastDist

  lastDist := 0

  repeat        
    if Sensor.getArmButton==1
      Motor.Halt
      waitcnt(clkfreq/5+cnt)
      if Sensor.getArmButton==1' or Sensor.getCMMiddle < 5
        quit
    elseif Sensor.GetMiddleCM < 4
      Motor.Halt 
      waitcnt(clkfreq/5+cnt)
      if Sensor.getMiddleCM < 4
        Motor.Forward(MED_SPEED, 200)
        quit
    elseif Sensor.GetMiddleCM > 3500
      Motor.Halt 
      waitcnt(clkfreq/5+cnt)
      if Sensor.getMiddleCM > 3500
        Motor.Forward(MED_SPEED, 200)
        quit

    if Sensor.getMiddleMM > lastDist - 2 and Sensor.getMiddleMM < lastDist + 2 and Sensor.getMiddleMM < 60
      quit
      
        
    if Sensor.getMiddleMM > lowestDist + 30
      Motor.Backward(MED_SPEED, 400)
      LostCanScan

    if Sensor.getMiddleMM < 70
      Motor.SpinRight(MED_SPEED, 100)

    Motor.ForwardVerbose(MED_SPEED, MED_SPEED+20, 10)

    lastDist := Sensor.getMiddleMM
    


    'if Sensor.getMiddleMM < 60
    '  Claw.Close
     ' waitcnt(clkfreq/5+cnt)
     ' Claw.Open

  Claw.Close
  waitcnt(clkfreq/3*2+cnt)
  Claw.Open
  waitcnt(clkfreq/3*2+cnt)
  Claw.Close
  waitcnt(clkfreq/3*2+cnt)

PRI ScanBlock | omega

  omega :=  StartingAngle - 80 

  TurnToHeading(startingAngle+90)

  lowestDist := 5000
  lowestDistAngle := 0
  
  repeat until sensor.getDegrees < omega
    Motor.SpinRight(FAST_SPEED, 10)
    if Sensor.getMiddleMM < lowestDist
      waitcnt(clkfreq/10+cnt)
      if Sensor.getMiddleMM < lowestDist
        lowestDist := Sensor.getMiddleMM
        lowestDistAngle := Sensor.getDegrees

  TurnToHeadingAndDistance(lowestDistAngle, lowestDist)

PRI LostCanScan | omega

  omega :=  sensor.getDegrees - 30 

  TurnToHeading(Sensor.getDegrees+30)

  lowestDist := 5000
  lowestDistAngle := 0
  
  repeat until sensor.getDegrees < omega
    Motor.SpinRight(MED_SPEED, 10)
    if Sensor.getMiddleMM < lowestDist
      waitcnt(clkfreq/50+cnt)
      if Sensor.getMiddleMM < lowestDist
        lowestDist := Sensor.getMiddleMM
        lowestDistAngle := Sensor.getDegrees
      if Sensor.getMiddleMM < 50
        return
  
  TurnToHeadingAndDistance(lowestDistAngle, lowestDist)

PRI TurnToHeadingAndDistance(heading, dist) | endunit

  endunit := heading

  repeat until sensor.getDegrees == endunit
    if Sensor.getMiddleMM > dist - 2 and Sensor.getMiddleMM < dist + 2
      if Sensor.getDegrees > endunit - 1 and Sensor.getDegrees < endunit + 1
        quit
    if sensor.getDegrees < endunit
      Motor.SpinLeft(MED_SPEED, 10)
    elseif sensor.getDegrees > endunit
      Motor.SpinRight(MED_SPEED, 10)

    

PRI SetSpeedFast

  Speed := FAST_SPEED

PRI SetSpeedMedium

  Speed := MED_SPEED

PRI SetSpeedSlow

  Speed := LOW_SPEED

PRI UpdateInGreenTile

  if inGreenTile==1
    inGreenTile:=0
  else
    inGreenTile:=1  

'-----{ Debug Code }-----'

PRI DebugLoop | t, b
  {Dumps information to computer/lcd}

  '---{Init}---'
  LCD.Start(0)
  if DEBUG 
    PC.Start

  repeat
    Profiler[0].StartTimer

    if DEBUG
      UpdateComputer
       
      if not dbgSD==t
        PC.SendInt(String("SPEED-DEBUG"), t)
      dbgSD := t
    
    UpdateLCD

    if not DEBUG
        waitcnt(clkfreq/5+cnt)
    
    Profiler[0].Stoptimer
    t := Profiler[0].getTimeMs
    
PRI UpdateComputer

  'long dbgRR, dbgRG, dbgRB, dbgPM, dbgPR, dbgLOC, dbgHEAD, dbgCU, dbgMTRLS
  'long dbgMTRLD, dbgMTRAS, dbgMTRAD, dbgMTRRS, dbgMTRRD, dbgSL, dbgSD, dbgS1

  if not dbgQTIL==Sensor.getLeftQTI
    PC.SendInt(String("QTI-IL"), sensor.getLeftQTI)
  dbgQTIL := Sensor.getLeftQTI
  if not dbgQTIR==Sensor.getRightQTI
    PC.SendInt(String("QTI-IR"), sensor.getRightQTI)
  dbgQTIR := Sensor.getRightQTI
  if not dbgQTIM==Sensor.getMiddleQTI
    PC.SendInt(String("QTI-M"), sensor.getMiddleQTI)
  dbgQTIM := Sensor.getMiddleQTI
  PC.SendTuple5(String("BWSTRIP"), 0, Sensor.getLeftQTIColor, Sensor.getMiddleQTIColor, sensor.getRightQTIColor, 0)
  if not dbgPM==Sensor.getMiddleCM
    PC.SendInt(String("PING-M"), sensor.GetMiddleCM)
  dbgPM := Sensor.getMiddleCM
  if not dbgPR==Sensor.getRightCM
    PC.SendInt(String("PING-R"), sensor.getRightCM)
  dbgPR := Sensor.getRightCM
  if not dbgLR==Sensor.getLeftRed
    PC.SendInt(String("CPALL-RED"), Sensor.getLeftRed)
  dbgLR := Sensor.getLeftRed
  if not dbgLG==Sensor.getLeftGreen
    PC.SendInt(String("CPALL-GREEN"), Sensor.getLeftGreen)
  dbgLG := Sensor.getLeftGreen
  if not dbgLB==Sensor.getLeftBlue
    PC.SendInt(String("CPALL-BLUE"), Sensor.getLeftBlue)
  dbgLB := Sensor.getLeftBlue
  if not dbgRR==Sensor.getRightRed
    PC.SendInt(String("CPALR-RED"), Sensor.getRightRed)
  dbgRR := Sensor.getRightRed
  if not dbgRG==Sensor.getRightGreen
    PC.SendInt(String("CPALR-GREEN"), Sensor.getRightGreen)
  dbgRG := Sensor.getRightGreen
  if not dbgRB==Sensor.getRightBlue
    PC.SendInt(String("CPALR-BLUE"), Sensor.getRightBlue)
  dbgRB := Sensor.getRightBlue
  if not dbgHEAD==Sensor.getDegrees
    PC.SendInt(String("HEADING"), Sensor.getDegrees)
  dbgHEAD := Sensor.getDegrees
  if not dbgLOC==location
    PC.SendStr(String("LOCATION"), location)
  dbgLOC := location
  if not dbgCU==Cog.GetUsedCogs
    PC.SendInt(String("COGS-USED"), Cog.GetUsedCogs)
  dbgCU := Cog.GetUsedCogs
  if not dbgSL==logicspeed
    PC.SendInt(String("SPEED-LOGIC"), logicspeed)
  dbgSL := logicspeed
  if not dbgS1==sensor.getFastLoopSpeed
    PC.SendInt(String("SPEED-SENSOR1"), sensor.getFastLoopSpeed)
  dbgS1 :=sensor.getFastLoopSpeed
  if not dbgS2==sensor.getSlowLoopSpeed
    PC.SendInt(String("SPEED-SENSOR3"), sensor.getSlowLoopSpeed)
  dbgS2 := sensor.getSlowLoopSpeed
  if not dbgS3==sensor.GetMediumLoopSpeed
    PC.SendInt(String("SPEED-SENSOR2"), sensor.GetMediumLoopSpeed)
  dbgS3 := sensor.GetMediumLoopSpeed
  if not dbgMTRLS== Motor.GetLeftSpeed
    PC.SendInt(String("MTRL-SPEED"), Motor.GetLeftSpeed)
  dbgMTRLS := Motor.GetLeftSpeed
  if not dbgMTRLD== Motor.getLeftDirection
    PC.SendStr(String("MTRL-DIR"), Motor.getLeftDirection)
  dbgMTRLD :=Motor.getLeftDirection
  if not dbgMTRRS==Motor.GetRightSpeed
    PC.SendInt(String("MTRR-SPEED"), Motor.GetRightSpeed)
  dbgMTRRS :=Motor.GetRightSpeed
  if not dbgMTRRD==Motor.getRightDirection
    PC.SendStr(String("MTRR-DIR"), motor.getRightDirection)
  dbgMTRRD :=Motor.getRightDirection
  if not dbgMTRAS==Motor.GetArmSpeed
    PC.SendInt(String("MTRA-SPEED"), Motor.GetArmSpeed)
  dbgMTRAS :=Motor.GetArmSpeed
  if not dbgMTRAD==Motor.getArmDirection
    PC.SendStr(String("MTRA-DIR"), Motor.getArmDirection)
  dbgMTRAD :=Motor.getArmDirection

'-----{ Locations }-----'

DAT

LINE_FOLLOWING         byte    "Line Following",0
OFF_LINE               byte    "Off Line", 0
CLOSE_OBJECT           byte    "Close Object", 0
WATER_TOWER            byte    "Water Tower",0
GREEN_LEFT             byte    "Green Corner Left",0
GREEN_RIGHT            byte    "Green Corner Right",0
BRIDGE                 byte    "Bridge", 0
SPEED_BUMPS            byte    "Speed Bumps",0
GRIDLOCK               byte    "Gridlock",0
CHEM_SPILL             byte    "Chemical Spill", 0
FINDING_CAN            byte    "Finding Can", 0
LIFTING_CAN            byte    "Lifting Can", 0 
FINDING_BLOCK          byte    "Finding Block", 0
PLACING_CAN            byte    "Placing Can", 0
FINISHED               byte    "Finished!", 0 