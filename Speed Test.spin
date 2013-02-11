CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  Mtr: "HB"

PUB Main

  Mtr.Start(1, 2, 3)

  Mtr.SetForward(100)

  repeat