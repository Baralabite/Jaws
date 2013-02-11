VAR

  long timer

PUB StartTimer

  timer := -cnt

PUB StopTimer

  timer += cnt - 544

PUB StopTimerx

  timer += cnt - 544
  return timer / (clkfreq / 1_000)

PUB getTimeMs

  return timer / (clkfreq / 1_000)

PUB getTimeSec

  return getTimeMs/1000

PUB getUpdatesPerSecond(time)

  'return 1_000 / (time / (clkfreq / 1_000))
  return 1000 / time