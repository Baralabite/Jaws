OBJ

  Serial: "Simple_Serial"
  Num: "Simple_Numbers"

VAR

  byte keys

PUB Start

  Serial.init(31, 30,9600)

PUB SendInt(key, val)

  Serial.Str(String("["))
  Serial.Str(key)
  Serial.Str(String(": "))
  Serial.Str(num.dec(val))
  Serial.Str(String("]"))


PUB SendStr(key, val)

  Serial.Str(String("["))
  Serial.Str(key)
  Serial.Str(String(": '"))
  Serial.Str(val)
  Serial.Str(String("']"))

PUB SendTuple5(key, a, b, c, d, e)

  Serial.Str(String("["))
  Serial.Str(key)
  Serial.str(String(": ("))
  Serial.Str(num.dec(a))
  Serial.str(string(", "))
  Serial.Str(num.dec(b))
  Serial.str(string(", "))
  Serial.Str(num.dec(c))
  Serial.str(string(", "))
  Serial.Str(num.dec(d))
  Serial.str(string(", "))
  Serial.Str(num.dec(e))
  Serial.str(string(")]"))