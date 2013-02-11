OBJ

  Serial: "Simple_Serial"
  num : "Simple_Numbers"

PUB Start(LCDPin)

  Serial.init(-1, LCDPin, 19200)

  Off
  ClearScreen
  On
  BacklightOn
  SendCommand(212)

PUB Stop

  Serial.finalize

PUB CR

  SendCommand(13)

PUB Left

  SendCommand(8)

PUB Right

  SendCommand(9)

PUB LF

  SendCommand(10)

PUB ClearScreen

  SendCommand(12)

PUB ClearLine(line)

  if line==1
    FirstLine
    Str(String("                    "))
    FirstLine
  elseif line==2
    SecondLine
    Str(String("                    "))
    SecondLine
  elseif line==3
    ThirdLine
    Str(String("                    "))
    ThirdLine
  elseif line==4
    ForthLine
    Str(String("                    "))
    ForthLine
  

PUB BacklightOn

  SendCommand(17)

PUB BacklightOff

  SendCommand(18)

PUB Off

  SendCommand(21)

PUB On

  SendCommand(22)

PUB FirstLine

  SendCommand(128)

PUB SecondLine

  SendCommand(148)

PUB ThirdLine

  SendCommand(168)

PUB ForthLine

  SendCommand(188)

PUB Str(msg)

  Serial.str(msg)

PUB StrCenter(StrAddr) | len, temp1, temp2

  len := strsize(StrAddr)
  temp1 := 10-(len/2)

  repeat temp2 from 1 to temp1
    Str(String(" "))
  Str(StrAddr)
  repeat temp2 from 1 to temp1
    Str(String(" "))

PUB StrRight(StrAddr) | len, temp1, temp2

  len := strsize(StrAddr)
  temp1 := 20-len

  repeat temp2 from 1 to temp1
    Str(String(" "))
  Str(StrAddr)

PUB StrLeft(StrAddr) | len, temp1, temp2

  len := strsize(StrAddr)
  temp1 := 20-len

  Str(StrAddr)
  repeat temp2 from 1 to temp1
    Str(String(" "))

PUB SendCommand(cmd)

  Serial.tx(cmd)

PUB Dec(n)

  Serial.str(num.dec(n))

PUB Boolean(msg)

  if msg == true
    Serial.str(string("true "))
  else
    Serial.str(string("false"))

PUB Error(l1,l2,l3,l4)

  SendCommand(225)
  SendCommand(220)
  ClearScreen
  Str(l1)
  CR
  Str(l2)
  CR
  Str(l3)
  CR
  Str(l4)
  repeat

PUB Beep

  SendCommand(220)

PUB Beepx(pitch)

  SendCommand(220+pitch)

PUB SmallBeep

  SendCommand(208)
  Beep
  SendCommand(211)

PUB SmallBeepx(pitch)

  SendCommand(208)
  Beepx(pitch)
  SendCommand(211)
  