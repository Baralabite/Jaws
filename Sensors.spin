CON

  {Normal QTI Calibration}

  LeftThreshold   = 1400 '900
  MiddleThreshold = 800 '700
  RightThreshold  = 1500 '900

  LeftThreshold1 = 2100
  MiddleThreshold1 = 1000
  RightThreshold1 = 2000

  LeftThreshold2 = 2500         '3D - Bridge
  MiddleThreshold2 = 1500
  RightThreshold2 = 2500

  {Sensitivity}
  
  Sensitivity = 20

  {Normal CPAL Calibration}

  LeftGreenRed = 26
  LeftGreenGreen = 61
  LeftGreenBlue = 59

  RightGreenRed = 34
  RightGreenGreen = 56
  RightGreenBlue = 67

  {Misc}

  FastSyncSpeed = 8
  SlowSyncSpeed = 18
  MediumSyncSpeed = 35

  UpdateDelayThreshold = 50

  UltrasonicMax = 100

  OFFLINE_THRESHOLD = 10

  BRIDGE_THRESHOLD = 1200

  TopArmQTICalibration = 100_000
  BottomArmQTICalibration = 100_000

  DegreesDivisor = 9831/360

  FeelerCalibration = 4100
  FeelerSensitivity = 2000
  FeelerSensitivity1 = 500

OBJ

  QTI           : "QTIDriver"

  CPALLeft      : "ColorPAL"
  CPALRight     : "ColorPAL"
  
  Ping          : "Ping"

  Profiler[6]   : "Profiler"

  Gyro          : "Gyroscope"

  Feeler        : "Feeler" 
  
VAR

  byte LeftQTIPin, RightQTIPin, MiddleQTIPin, TopArmQTIPin, BottomARmQTIPin, LeftColorPALPin, RightColorPALPin, CPALLeftPin, CPALRightPin
  
  byte LeftRed, LeftGreen, LeftBlue
  byte RightRed, RightGreen, RightBlue

  byte FastLoopCog, MediumLoopCog, SlowLoopCog

  long FastLoopSpeed, FastLoopSpeedFull, FastLoopWait
  long MediumLoopSpeed, MediumLoopSpeedFull, MediumLoopWait  
  long SlowLoopSpeed, SlowLoopSpeedFull, SlowLoopWait

  long stack[150]
  
  long LeftQTIRaw, MiddleQTIRaw, RightQTIRaw
  byte LeftQTIColor, MiddleQTIColor, RightQTIColor
  long LeftQTICalibration, MiddleQTICalibration, RightQTICalibration

  long TopArmQTIRaw, BottomArmQTIRaw

  long MiddleCM, MiddleMM
  long RightCM, RightMM
  
  long SlowLoopCrashCounter
  long CPALLCntFromUpdate
  long CPALRCntFromUpdate

  long offlineCounter
  byte offline
  
  Long X, Y, Z, Degrees, highestY, relY, lowestY, FeelerRaw, Feeler_

PUB Start(CPALPinLeft, QTILeftPin, QTIMiddlePin, QTIRightPin, TopArmQTIPin_, BottomArmQTIPin_, CPALPinRight)

  CPALLeftPin := CPALPinLeft
  CPALRightPin := CPALPinRight
  LeftQTIPin := QTILeftPin
  MiddleQTIPin := QTIMiddlePin
  RightQTIPin := QTIRightPin
  LeftColorPALPin := CPALLeftPin
  RightColorPALPin := CPALRightPin
  TopArmQTIPin := TopArmQTIPin_
  BottomArmQTIPin := BottomArmQTIPin_

  'InitButtons
  LaunchCogs

'-----[ Cogs ]-----'

PUB LaunchCogs

  StartFastLoopCog
  StartMediumLoopCog
  StartSlowLoopCog

PUB StartFastLoopCog

  FastLoopCog := cognew(FastLoop, @stack[0])

PUB StopFastLoopCog

  cogstop(FastLoopCog)

PUB RestartFastLoopCog

  StopFastLoopCog
  waitcnt(clkfreq/100+cnt)
  StartFastLoopCog

PUB StartMediumLoopCog

  MediumLoopCog := cognew(MediumLoop, @stack[50])

PUB StopMediumLoopCog

  cogstop(MediumLoopCog)

PUB RestartMediumLoopCog

  StopMediumLoopCog
  waitcnt(clkfreq/100+cnt)
  StartMediumLoopCog

PUB StartSlowLoopCog

  SlowLoopCog := cognew(SlowLoop, @stack[100])

PUB StopSlowLoopCog

  cogstop(SlowLoopCog)

PUB RestartSlowLoopCog

  StopSlowLoopCog
  waitcnt(clkfreq/100+cnt)
  StartSlowLoopCog

PUB StopCogs

  StopFastLoopCog
  StopMediumLoopCog
  StopSlowLoopCog

'-----[ Misc] -----'

PUB InitButtons

  DIRA[16..18]~

PUB SetQTICalibration(l, m, r)

  LeftQTICalibration := l
  MiddleQTICalibration := m
  RightQTICalibration := r

PUB SetNormalCalibration

  LeftQTICalibration := LeftThreshold
  RightQTICalibration := RightThreshold
  MiddleQTIcalibration := MiddleThreshold

PUB SetSpeedBumpsCalibration

  LeftQTICalibration := LeftThreshold1
  RightQTICalibration := RightThreshold1
  MiddleQTIcalibration := MiddleThreshold1

PUB Set3DCalibration

  LeftQTICalibration := LeftThreshold2
  RightQTICalibration := RightThreshold2
  MiddleQTIcalibration := MiddleThreshold2

PUB FastLoop

  QTI.addQTI(LeftQTIPin)
  QTI.addQTI(MiddleQTIPin)  
  QTI.addQTI(RightQTIPin)

  SetNormalCalibration

  repeat
    'Profiler[1].StartTimer
    Profiler[0].StartTimer

    LeftQTIRaw := QTI.GetRaw(LeftQTIPin)
    MiddleQTIRaw := QTI.getRaw(MiddleQTIPin)
    RightQTIRaw := QTI.getRaw(RightQTIPin) 

    if offlineCounter > OFFLINE_THRESHOLD
      offLine := 1
      offlineCounter := 0
    elseif MiddleQTIRaw > MiddleQTICalibration
      offLine := 0
      offlineCounter := 0
    elseif MiddleQTIRaw < MiddleQTICalibration
      offlineCounter++

    Profiler[0].StopTimer
    FastLoopSpeed := Profiler.getTimeMs
    {if FastLoopSpeed < FastSyncSpeed
      FastLoopWait := FastSyncSpeed - FastLoopSpeed
      pause(FastLoopWait)
    else
      FastLoopWait := -1
    Profiler[1].StopTimer
    FastLoopSpeedFull := Profiler[1].getTimeMs}

PUB MediumLoop

  Gyro.Start

  repeat
    Profiler[5].StartTimer
    Profiler[4].StartTimer

    MiddleMM := Ping.Millimeters(6)
    RightMM := Ping.Millimeters(7)
    MiddleCM := MiddleMM/10
    RightCM := RightMM/10
    MiddleMM <#= UltrasonicMax*10
    RightMM <#= UltrasonicMax*10
    MiddleCM <#= UltrasonicMax
    RightCM <#= UltrasonicMax

    Feeler.GetRaw(19, 1, @FeelerRaw)
    if FeelerRaw > FeelerCalibration + FeelerSensitivity1
      waitcnt(clkfreq/20+cnt)
      if FeelerRaw > FeelerCalibration + FeelerSensitivity1
        Feeler_ := -1      
    elseif FeelerRaw < FeelerCalibration - FeelerSensitivity
      waitcnt(clkfreq/20+cnt)
      if FeelerRaw < FeelerCalibration - FeelerSensitivity
        Feeler_ := 1
    else
      Feeler_ := 0

    Gyro.Update
    X := Gyro.GetX
    Y := Gyro.GetY
    Z := Gyro.getZ
    Degrees := Z/DegreesDivisor
    relY := Gyro.GetRelativeY
    if Gyro.getRelativeY > highestY
      highestY := Gyro.getRelativeY
    if Gyro.getRelativeY < lowestY
      lowestY := Gyro.GetRelativeY

    SlowLoopCrashCounter++
    if SlowLoopCrashCounter > 30
      RestartSlowLoopCog
      SlowLoopCrashCounter := 0

    Profiler[4].StopTimer
    MediumLoopSpeed := Profiler[4].getTimeMs
    if MediumLoopSpeed < mediumSyncSpeed
      MediumLoopWait := mediumSyncSpeed - MediumLoopSpeed
      pause(MediumLoopWait)
    else
      MediumLoopWait := -1
    MediumLoopSpeedFull := Profiler[5].StopTimerX

PUB getFeelerButton

  return INA[20]

PUB getHighestY

  return HighestY

PUB getRelY

  return relY

PUB getLowestY

  return lowestY

PUB SlowLoop

  CPALLeft.Init(4)
  CPALRight.Init(5) 

  repeat
    Profiler[3].StartTimer
    Profiler[2].StartTimer

    '-----{Update Readings, and check for any crashes}-----'

    if LeftRed == CPALLeft.GetRed and LeftGreen == CPALLeft.GetGreen and LeftBlue == CPALLeft.GetBlue
      CPALLCntFromUpdate++
      if CPALLCntFromUpdate > 10
        CPALLeft.Restart(CPALLeftPin)
        CPALLCntFromUpdate := 0
    else
      LeftRed := CPALLeft.GetRed
      LeftGreen := CPALLeft.GetGreen
      LeftBlue := CPALLeft.GetBlue
      CPALLCntFromUpdate := 0

    if RightRed == CPALRight.GetRed and RightGreen == CPALRight.GetGreen and RightBlue == CPALRight.GetBlue
      CPALRCntFromUpdate++
      if CPALRCntFromUpdate > 10
        CPALRight.Restart(CPALRightPin)
        CPALRCntFromUpdate := 0
    else
      RightRed := CPALRight.GetRed
      RightGreen := CPALRight.GetGreen
      RightBlue := CPALRight.GetBlue
      CPALRCntFromUpdate := 0

    SlowLoopCrashCounter := 0

    Profiler[2].StopTimer
    SlowLoopSpeed := Profiler[2].getTimeMs
    if SlowLoopSpeed < SlowSyncSpeed
      SlowLoopWait := SlowSyncSpeed - SlowLoopSpeed
      pause(SlowLoopWait)
    else
      SlowLoopWait := -1
    Profiler[3].StopTimer
    SlowLoopSpeedFull := Profiler[3].getTimeMs

PUB GetLeftCrashCounter

  return cpalLCntFromUpdate

PUB GetRightCrashCounter

  return cpalRCntFromUpdate

PUB GetcpalCrashCounter

  return SlowLoopCrashCounter

PUB GetFastLoopSpeed

  return FastLoopSpeed

PUB GetMediumLoopSpeed

  return MediumLoopSpeed

PUB GetSlowLoopSpeed

  return SlowLoopSpeed

PUB GetFastLoopSpeedFull

  return FastLoopSpeedFull

PUB getMediumLoopSpeedFull

  return MediumLoopSpeedFull

PUB GetSlowLoopSpeedFull

  return SlowLoopSpeedFull  

PUB GetFastWait

  return FastLoopWait

PUB GetMediumWait

  return MediumLoopWait

PUB GetSlowWait

  return SlowLoopWait

PUB IsFastLoopSlowerThanSync

  if FastLoopSpeed > FastSyncSpeed
    return true
  else
    return false

PUB IsSlowLoopSlowerThanSync

  if SlowLoopSpeed > SlowSyncSpeed
    return true
  else
    return false

PUB GetMiddleMM

  return MiddleMM

PUB GetRightMM

  return RightMM

PUB GetMiddleCM

  return MiddleCM

PUB GetRightCM

  return RightCM

PUB GetLeftCPALColor

  if LeftRed > LeftGreenRed - Sensitivity and LeftRed < LeftGreenRed + Sensitivity
    if LeftGreen > LeftGreenGreen - Sensitivity and LeftGreen < LeftGreenGreen + Sensitivity
      if LeftBlue > LeftGreenBlue - Sensitivity and LeftBlue < LeftGreenBlue + Sensitivity
        return 1
      else
        return 0
    else
      return 0
  else
    return 0

PUB GetRightCPALColor

  if RightRed > RightGreenRed - Sensitivity and RightRed < rightGreenRed + Sensitivity
    if RightGreen > RightGreenGreen - Sensitivity and RightGreen < RightGreenGreen + Sensitivity
      if RightBlue > RightGreenBlue - Sensitivity and RightBlue < RightGreenBlue + Sensitivity
        return 1
      else
        return 0
    else
      return 0
  else
    return 0    

PUB GetLeftQTI

  return LeftQTIRaw

PUB GetMiddleQTI

  return MiddleQTIRaw

PUB GetRightQTI

  return RightQTIRaw

PUB GetBottomArmQTI

  return QTI.getRaw(BottomArmQTIPin) 

PUB GetTopArmQTI

  return QTI.getRaw(TopArmQTIPin) 

PUB GetLeftQTIColor

  if LeftQTIRaw > LeftQTICalibration
    return 1
  else
    return 0

PUB getMiddleQTIColor

  if MiddleQTIRaw > MiddleQTICalibration
    return 1
  else
    return 0

PUB getRightQTIColor

  if RightQTIRaw > RightQTICalibration
    return 1
  else
    return 0

PUB getTopArmQTIColor

  if QTI.getRaw(TopArmQTIPin)  < TopArmQTICalibration
    return 1
  else
    return 0

PUB getBottomArmQTIColor

  if QTI.getRaw(BottomArmQTIPin)  < BottomArmQTICalibration
    return 1
  else
    return 0

PUB GetLeftRed

  return LeftRed

PUB GetLeftGreen

  return LeftGreen

PUB GetLeftBlue

  return LeftBlue

PUB GetRightRed

  return RightRed 

PUB GetRightGreen

  return RightGreen

PUB GetRightBlue

  return RightBlue

PUB GetArmButton

  return INA[16]

PUB GetButtonLeft

  return INA[17]

PUB GetButtonRight

  return INA[18]

PUB GetLeftCalibration

  return LeftQTICalibration

PUB GetMiddleCalibration

  return RightQTICalibration

PUB GetRightCalibration

  return RightQTICalibration

PUB GetLeftRedCPALCalibration

  return LeftGreenRed

PUB GetLeftGreenCPALCalibration

  return LeftGreenGreen

PUB GetLeftBlueCPALCalibration

  return LeftGreenBlue

PUB GetRightRedCPALCalibration

  return RightGreenRed

PUB GetRightGreenCPALCalibration

  return RightGreenGreen

PUB GetRightBlueCPALCalibration

  return RightGreenBlue

PUB isOffline

  return offline

PUB getOfflineCounter

  return offlineCounter

PUB getOnBridge

  return getOnBridgeScore == 3
  
PUB getOnBridgeScore | n

  n := 0

  if GetLeftQTI > BRIDGE_THRESHOLD
    n++
  if GetMiddleQTI > BRIDGE_THRESHOLD
    n++
  if GetRightQTI > BRIDGE_THRESHOLD
    n++
  if getMiddleMM < 200
    n++
    
  return n

PUB GetDegrees

  return Degrees

PUB GetX

  return X

PUB GetY

  return Y

PUB GetZ

  return Z

PUB GetFeelerRaw

  return FeelerRaw

PUB GetFeeler

  return Feeler_                

PRI Pause(ms)

  waitcnt(clkfreq/(1000/ms)+cnt)
                                