var

  long stack[5]
  byte cog

PUB StopCog(id)

  COGSTOP(id)

PUB GetUsedCogs | x

  x := 0
  stack := false
  x := cognew(TempCog, @stack[0])
  StopCog(x)
  return x

PUB CogsAvaliable

  if GetUsedCogs  < 8
    return true
  else
    return false

PUB getCPU

  return GetUsedCogs*8

PRI TempCog
  Abort  