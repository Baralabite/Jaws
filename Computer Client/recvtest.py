import pyprop as robot

def hbh(data):
    print "Heartbeat", data

recv = robot.Reciever()
recv.start(10)
recv.registerListener("Cat", hbh)

while 1:
    recv.update()
