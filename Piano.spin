CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  Ping: "Ping"
  LCD: "LCD"

PUB Main

  LCD.Start(1)

  LCD.SendCommand(208)
  LCD.SendCommand(200)

  repeat

    LCD.ClearScreen
    LCD.Dec(Ping.Centimeters(0))

    LCD.SendCommand(220+(Ping.Centimeters(0)/4))

    waitcnt(clkfreq/16+cnt)

    