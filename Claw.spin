OBJ

  Servo: "Servo"

VAR

  byte ForceDir

PUB Open

  'if not ForceDir == 2
    Servo.set(21, 1400)

PUB Close

  'if not ForceDir == 1
    Servo.set(21, 2150)

PUB HalfOpen

  Servo.Set(21, 1900)

PUB Start

  Servo.Start
  ForceDir := -1

PUB Stop

  Servo.Stop

PUB ForceArmOpen

  Open
  ForceDir  := 1

PUB ForceArmClose

  Close
  ForceDir := 2

PUB UnforceArm

  ForceDir := -1
  