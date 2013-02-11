import pygame, math, threading, os

class Button:
    def __init__(self):
        self.pos = 0,0
        self.text = ""
        self.surf = None
        self.font = None
        self.btext = None
        self.bg = (0, 255, 0)
        self.chC = (0,100, 0)
        self.eventHandler = None
        self.size = 0,0
        self.mouseOver = False
        self.wasClicked = False
        self.command = None
        self.visible = True

    def start(self, surf, pos, text, e, command):
        self.font = pygame.font.Font(None, 36)
        self.btext = self.font.render(text, 1, self.bg)
        self.text = text
        self.size = self.btext.get_width(), self.btext.get_height()
        self.pos = pos
        self.surf = surf
        self.eventHandler = e
        self.command = command

        self.eventHandler.registerEvent(text+"MouseMoveListener", pygame.MOUSEMOTION, self.mouseMove)

    def stop(self):
        pass

    def mouseMove(self, e):
        pos = e.dict['pos']
        if pos[0] > self.pos[0] and pos[0] < self.pos[0] + self.size[0]:
            if pos[1] > self.pos[1] and pos[1] < self.pos[1] + self.size[1]:
                self.mouseOver = True
            else:
                self.mouseOver = False
        else:
            self.mouseOver = False

    def isFocused(self):
        return self.mouseOver

    def isClicked(self):
        if self.mouseOver and pygame.mouse.get_pressed()[0]:
            return True
        else:
            return False

    def update(self):
        if self.visible:    
            if self.wasClicked == True and pygame.mouse.get_pressed()[0]==0:
                self.wasClicked = False
                self.command()
            else:
                self.wasClicked = self.isClicked()
            if self.isFocused():
                self.surf.blit(self.font.render(self.text, 1, self.chC), self.pos)
                pygame.draw.rect(self.surf, self.bg, pygame.Rect(self.pos[0]-3, self.pos[1]-3, self.size[0]+6, self.size[1]+6), 2)
            else:
                self.surf.blit(self.font.render(self.text, 1, self.bg), self.pos)
                pygame.draw.rect(self.surf, self.bg, pygame.Rect(self.pos[0]-3, self.pos[1]-3, self.size[0]+6, self.size[1]+6), 2)

class Graph:
    def __init__(self):
        self.pos = 0,0
        self.size = 0,0
        self.bg = (255, 255, 255)
        self.surf = None
        self.channels = {}
        self.channelData = []
        self.min = 0
        self.max = 100
        self.width = 100
        self.increment = 0
        self.visible = True

    def start(self, surf, pos, size, max_, min_, width):
        self.pos = pos
        self.size = size
        self.surf = surf
        self.min = min_
        self.max = max_
        self.width = width
        self.increment = float(self.size[0]) / float(self.width), float(self.size[1]) / float(self.max-self.min)

    def addChannel(self, id_, color):
        self.channels[id_] = color, []

    def addChannelData(self, id_, data):
        self.channels[id_][1].append(data)

    def update(self):
        if self.visible:
            pygame.draw.rect(self.surf, self.bg, pygame.rect.Rect(self.pos[0], self.pos[1], self.size[0], self.size[1]))
            pygame.draw.rect(self.surf, (255,0,0), pygame.rect.Rect(self.pos[0], self.pos[1], self.size[0], self.size[1]), 3)
            self.draw()

    def draw(self):
        for x in self.channels:
                col = self.channels[x][0]
                dat = self.channels[x][1]
                for y in range(3, len(dat)):
                    data = dat[y]
                    oldData = dat[y-1]
                    if data > self.max:
                        data = self.max
                    if oldData > self.max:
                        oldData = self.max
                    if y > self.width*self.increment[0]:
                        self.channels[x] = col, []
                    if y==0:
                        pass
                        #pos = self.normalizePos((self.normalizeX(y), self.normalizeY(data)))
                        #pygame.draw.line(self.surf, col, (self.pos[0], self.pos[1]+self.size[1]), pos, 5)
                    else:
                        pos1 = self.normalizePos((y-1*self.increment[0], self.normalizeY(oldData)))
                        pos2 = self.normalizePos((y-self.increment[0], self.normalizeY(data)))
                        pygame.draw.line(self.surf, col, pos1, pos2, 2)

    def normalizePos(self, pos):
        x = self.pos[0] + pos[0]
        y = self.pos[1] + self.size[1] - pos[1]
        return x,y

    def normalizeX(self, x):
        return x * self.increment[0]

    def normalizeY(self, y):
        return y * self.increment[1]

class Label:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.visible = True

    def start(self, surf, pos, color, text, size=36):
        self.pos = pos
        self.color = color
        self.text = text
        self.font = pygame.font.Font(None, 36)
        self.surf = surf

    def stop(self):
        pass

    def update(self):
        if self.visible:
            text = self.font.render(self.text, 1, self.color)
            self.surf.blit(text, self.pos)

class ValueBox:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.value = 0
        self.visible = True

    def start(self, surf, pos, color, text, size=36, value=0):
        self.pos = pos
        self.color = color
        self.text = text
        self.font = pygame.font.Font(None, size)
        self.surf = surf
        self.value = value

    def stop(self):
        pass

    def getValue(self):
        return self.value

    def setValue(self, value):
        self.value = value

    def update(self):
        if self.visible:
            text = self.font.render(self.text+": "+str(self.value), 1, self.color)
            self.surf.blit(text, self.pos)

class CheckBox:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.value = 0
        self.wasClicked = False
        self.eventHandler = None
        self.size = 0,0
        self.visible = True

    def start(self, surf, pos, color, text, e, size=36, value=0):
        self.pos = pos
        self.color = color
        self.text = text
        self.font = pygame.font.Font(None, 36)
        self.surf = surf
        self.value = value
        self.mouseOver = False
        self.eventHandler = e
        self.eventHandler.registerEvent(text+"MouseMoveListener", pygame.MOUSEMOTION, self.mouseMove)

    def stop(self):
        pass

    def getValue(self):
        return self.value

    def setValue(self, value):
        self.value = value

    def update(self):
        if self.visible:
            text = self.font.render(self.text, 1, self.color)
            self.surf.blit(text, self.pos)
            self.size = text.get_width() + 10 + text.get_height(), text.get_height()
            pygame.draw.rect(self.surf, self.color, (self.pos[0] + text.get_width() + 10, self.pos[1], text.get_height(), text.get_height()), 4)
            if self.value==1:
                pygame.draw.circle(self.surf, self.color, (self.pos[0]+text.get_width()+11+(text.get_height()/2), self.pos[1] + text.get_height()/2+1), text.get_height()/3)

            if self.wasClicked == True and pygame.mouse.get_pressed()[0]==0:
                self.wasClicked = False
                if self.value==1:
                    self.value = 0
                else:
                    self.value = 1
            else:
                self.wasClicked = self.isClicked()

    def mouseMove(self, e):
        pos = e.dict['pos']
        if pos[0] > self.pos[0] and pos[0] < self.pos[0] + self.size[0]:
            if pos[1] > self.pos[1] and pos[1] < self.pos[1] + self.size[1]:
                self.mouseOver = True
            else:
                self.mouseOver = False
        else:
            self.mouseOver = False

    def isFocused(self):
        return self.mouseOver

    def isClicked(self):
        if self.mouseOver and pygame.mouse.get_pressed()[0]:
            return True
        else:
            return False

"""class Tab:
    def __init__(self):
        self.tabs = {}
        self.surf = None
        self.pos = pos
        self.size = size

    def start(self, surf, pos, size, tabOneName):
        self.surf = surf
        self.pos = pos
        self.size = size
        self.addTab(tabOneName)

    def addTab(self, name):
        self.tabs[name] = {}
        self.tabs[name][name+'MainButton'] = Button()
        self.tabs[name][name+'MainButton'].start(self.surf, 
        self.widgets[name] = Button()
        self.widgets[name].start(surf, pos, text, self.eventHandler, command)

    def deleteTab(self, name):
        del self.tabs[name]

    def update(self):
        pass"""

class Compass:
    def __init__(self):
        self.surf = None
        self.radius = 0
        self.pos = 0,0
        self.needleColor = (255,0,0)
        self.bgColor = (255, 255, 255)
        self.angle = 0
        self.font = None
        self.visible = True

    def start(self, surf, pos, radius):
        self.pos = pos
        self.radius = radius
        self.surf = surf
        self.font = pygame.font.Font(None, 24)

    def stop(self):
        pass

    def setAngle(self, angle):
        self.angle = angle

    def update(self):
        if self.visible:
            x = self.font.render(str(self.angle), 1, (0, 255, 0))
            self.surf.blit(x, (self.pos[0]-self.radius-10, self.pos[1]-self.radius+10))
            pygame.draw.circle(self.surf, self.bgColor, self.pos, self.radius)
            pygame.draw.line(self.surf, self.needleColor, self.pos, (self.pos[0]+self.polarToCartesian(self.normalizeAngle(self.angle-90), self.radius)[0],
                                                                     self.pos[1]+self.polarToCartesian(self.normalizeAngle(self.angle-90), self.radius)[1]), 4)

    def normalizeAngle(self, angle):
        """Returns int of normalized argument angle."""
        if angle > 0 and angle < 360:
            return angle
        elif angle > 360:
            x = float(angle) / 360.0
            y = x - int(x)
            z = y * 360.0
            return int(round(z))
        elif angle < 0 and angle > -360:
            return 360+angle
        elif angle < 0 and angle < -360:
	    x = float(angle) / 360.0
	    y = x - int(x)
	    z = y * 360.0
	    return int(360+z)


    def polarToCartesian(self, angle, length):
        try:
            a = math.radians(angle)
            x = length * math.cos(a)
            y = length * math.sin(a)
            return x, y
        except:
            return 0,0

class ProgressBar:
    def __init__(self):
        self.surf = None
        self.size = 0,0
        self.pos = 0,0
        self.value = 0
        self.max = 100
        self.font = None
        self.incrementX = 0
        self.edgeColor = (0,200,0)
        self.innerColor = (0, 255,0)
        self.visible = True
        self.text = ""
        self.colorIncrement = 0

    def start(self, surf, pos, size, text=""):
        self.pos = pos
        self.size = size
        self.surf = surf
        self.font = pygame.font.Font(None, 16)
        self.incrementX = float(self.size[0]-6) / float(self.max)
        self.text = text
        if self.max < 255:
            self.colorIncrement = 255.0 / float(self.max)
        elif self.max > 255:
            self.colorIncrement = float(self.max) / 255.0

    def stop(self):
        pass

    def setValue(self, value):
        self.value = value

    def update(self):
        if self.visible:
            if self.value > self.max:
                self.value = self.max
            x = self.font.render(self.text+str(self.value), 1, (0, 0, 255))
            pygame.draw.rect(self.surf, self.edgeColor, (self.pos[0], self.pos[1], self.size[0], self.size[1]), 3)
            w = self.value*self.incrementX
            if (255.0-(self.value*self.colorIncrement)) <= 255 and (0 + (self.value*self.colorIncrement)) <= 255:
                self.innerColor = (255.0 - (self.value * self.colorIncrement), 0 + (self.value*self.colorIncrement), 0)
            pygame.draw.rect(self.surf, self.innerColor, (self.pos[0]+4, self.pos[1]+3, w, self.size[1]-6))
            self.surf.blit(x, (self.pos[0]+(self.size[0]/2)-(x.get_width()/2), self.pos[1]+(self.size[1]/2)-(x.get_height()/2)+1))

class Frame:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.size = 0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.visible = True

    def start(self, surf, text, pos, size, color):
        self.pos = pos
        self.color = color
        self.text = text
        self.font = pygame.font.Font(None, 24)
        self.surf = surf
        self.size = size

    def stop(self):
        pass

    def update(self):
        if self.visible:
            text = self.font.render(self.text, 1, self.color)
            self.surf.blit(text, self.pos)
            pygame.draw.rect(self.surf, self.color, (self.pos[0], self.pos[1]+text.get_height()+3, self.size[0], self.size[1]-(text.get_height()+3)), 3)

class QTIBWStrip:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.visible = True
        self.values = [0,0,0,0,0]
        self.segmentSize = 0

    def start(self, surf, pos, size):
        self.pos = pos
        self.size = size
        self.surf = surf
        self.segmentSize = self.size[0] / 5

    def stop(self):
        pass

    def setValues(self, values):
        self.values = values

    def update(self):
        if self.visible:
            for x in range(len(self.values)):
                val = self.values[x]
                if val==1:
                    pygame.draw.rect(self.surf, (0,0,0), (self.pos[0]+(x*self.segmentSize), self.pos[1], self.segmentSize, self.size[1]))
                    pygame.draw.rect(self.surf, (255,0,0), (self.pos[0]+(x*self.segmentSize), self.pos[1], self.segmentSize, self.size[1]), 2)
                if val==0:
                    pygame.draw.rect(self.surf, (255,255,255), (self.pos[0]+(x*self.segmentSize), self.pos[1], self.segmentSize, self.size[1]))
                    pygame.draw.rect(self.surf, (255,0,0), (self.pos[0]+(x*self.segmentSize), self.pos[1], self.segmentSize, self.size[1]), 2)
                    
            pygame.draw.rect(self.surf, (255,0,0), (self.pos[0], self.pos[1], self.size[0], self.size[1]), 3)

class PictureBox:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.size = 0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.visible = True
        self.path = ""

    def start(self, surf, text, pos, size, color, filename):
        self.pos = pos
        self.color = color
        self.text = text
        self.font = pygame.font.Font(None, 24)
        self.surf = surf
        self.size = size
        self.image = pygame.image.load(os.path.join("Data", filename))
        self.path = filename
        self.image.convert()
        self.image = pygame.transform.scale(self.image, (self.size[0]-6, self.size[1]-26))

    def stop(self):
        pass

    def setImage(self, path):
        self.path = path
        self.image = pygame.image.load(os.path.join("Data", path))
        self.image.convert()
        self.image = pygame.transform.scale(self.image, (self.size[0]-6, self.size[1]-26)) 

    def getImage(self):
        return self.path

    def update(self):
        if self.visible:
            text = self.font.render(self.text, 1, self.color)
            self.surf.blit(text, self.pos)
            self.surf.blit(self.image, (self.pos[0]+3, self.pos[1]+text.get_height()+6))
            pygame.draw.rect(self.surf, self.color, (self.pos[0], self.pos[1]+text.get_height()+3, self.size[0], self.size[1]-(text.get_height()+3)), 3)

class Map:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.size = 0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.visible = True
        self.robot = None

    def start(self, surf, text, pos, size, color):
        self.pos = pos
        self.color = color
        self.text = text
        self.font = pygame.font.Font(None, 24)
        self.surf = surf
        self.size = size
        self.drawingSurf = pygame.Surface((self.size[0]-6, self.size[1]-26))
        self.drawingSurf.fill((255,255,255))
        self.robot = Robot()
        self.robot.start(self.surf, (self.pos[0]+self.size[0]/2, self.pos[1]+self.size[1]/2))

    def stop(self):
        pass

    def update(self):
        if self.visible:
            self.pullRobotWithinBounds()
            
            text = self.font.render(self.text, 1, self.color)
            self.surf.blit(text, self.pos)
            
            robotPos = self.robot.getPos()[0]-self.pos[0], self.robot.getPos()[1]-self.pos[1]
            pygame.draw.circle(self.drawingSurf, (0,0,0), robotPos, 2)
            
            self.surf.blit(self.drawingSurf, (self.pos[0]+3,self.pos[1]+text.get_height()+6))
            pygame.draw.rect(self.surf, self.color, (self.pos[0], self.pos[1]+text.get_height()+3, self.size[0], self.size[1]-(text.get_height()+3)), 3)

            self.robot.update()

    def pullRobotWithinBounds(self):
        if self.robot.pos[0] < self.pos[0]:
            self.robot.pos = self.pos[0], self.robot.pos[1]
        elif self.robot.pos[0] > self.pos[0]+self.size[0]:
            self.robot.pos = self.pos[0]+self.size[0], self.robot.pos[1]

        if self.robot.pos[1] < self.pos[1]:
            self.robot.pos = self.robot.pos[0], self.pos[1]+10
        elif self.robot.pos[1] > self.pos[1]+self.size[1]:
            self.robot.pos = self.robot.pos[0], self.pos[1]+self.size[1]

class Robot:
    def __init__(self):
        self.pos = 0,0
        self.surf = None
        self.speed = 1
        self.heading = self.normalizeAngle(0)
        self.vector = 0,0

    def start(self, surf, pos):
        self.pos = pos
        self.surf = surf

    def stop(self):
        pass

    def update(self):
        #self.forward()
        pygame.draw.circle(self.surf, (0,255,0), self.pos, 6)

    def getPos(self):
        return self.pos

    def getHeading(self):
        return self.heading

    def setHeading(self, heading):
        self.heading = self.normalizeAngle(heading)

    def setPos(self, pos):
        self.pos = pos

    def getSpeed(self):
        return self.speed

    def setSpeed(self, speed):
        self.speed = speed

    def forward(self):
        relativePos = self.polarToCartesian(self.heading, self.speed)
        self.pos = (self.pos[0]+relativePos[0], self.pos[1]+relativePos[1])

    def backward(self):
        relativePos = self.polarToCartesian(180-self.heading, self.speed)
        self.pos = (self.pos[0]+relativePos[0], self.pos[1]+relativePos[1])

    def left(self, angle):
        self.heading = self.heading-angle

    def right(self, angle):
        self.heading = self.heading+angle

    def normalizeAngle(self, a):
        """Returns int of normalized argument angle."""
        angle = a - 90
        if angle >= 0 and angle < 360:
            return angle
        elif angle > 360:
            x = float(angle) / 360.0
            y = x - int(x)
            z = y * 360.0
            return int(round(z))
        elif angle < 0 and angle > -360:
            return 360+angle
        elif angle < 0 and angle < -360:
	    x = float(angle) / 360.0
	    y = x - int(x)
	    z = y * 360.0
	    return int(360+z)

    def polarToCartesian(self, angle, length):
        a = math.radians(float(angle))
        x = length * math.cos(a)
        y = length * math.sin(a)
        return int(x), int(y)

class TextBox:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.size = 0,0
        self.text = ""
        self.font = None
        self.surf = None
        self.visible = True
        self.max = 0
        self.onEnterFunc = None
        self.lastcommand = ""

    def start(self, surf, pos, size, onEnterFunc):
        self.surf = surf
        self.pos = pos
        self.size = size
        self.max = self.size[1] / 3
        self.font = pygame.font.Font(None, size[1])
        self.focused = False
        self.onEnterFunc = onEnterFunc


    def stop(self):
        pass

    def onType(self, e):
        print e.dict
        try:
            if self.focused:
                if e.dict['scancode']==14:
                    self.text = self.text[:len(self.text)-1]
                elif e.dict['scancode']==28:
                    if self.text != "":
                        self.onEnterFunc(self.text)
                        self.lastcommand = self.text
                        self.text = ""
                elif e.dict['scancode']==72:
                    self.text = self.lastcommand
                else:
                    self.text = self.text + e.dict['unicode']
        except:
            pass
        #self.text = self.text + data

    def onClick(self, e):
        if self.isMouseOver():
            self.focused = True
        else:
            self.focused = False

    def update(self):
        if self.visible:
            pygame.draw.rect(self.surf, (255,255,255), (self.pos[0], self.pos[1], self.size[0], self.size[1]), 0)
            text = self.font.render(self.text, 1, (0,0,0))

            if text.get_width() > self.size[0]- 5:
                self.text = self.text[:len(self.text)-1]
                text = self.font.render(self.text, 1, (0,0,0))

            if self.focused:
                pygame.draw.rect(self.surf, (255,0,0), (self.pos[0]+text.get_width()+2, self.pos[1]+3, 3, self.size[1]-6), 0)

            self.surf.blit(text, (self.pos[0], self.pos[1]+(self.size[1]-text.get_height())/2))

    def isMouseOver(self):
        mPos = pygame.mouse.get_pos()
        if mPos[0] > self.pos[0] and mPos[0] < self.pos[0] + self.size[0]:
            if mPos[1] > self.pos[1] and mPos[1] < self.pos[1] + self.size[1]:
                return True
            else:
                return False
        else:
            return False

class TextListBox:
    def __init__(self):
        self.pos = 0,0
        self.color = 0,0,0
        self.size = 0,0
        self.font = None
        self.surf = None
        self.visible = True
        self.lines = []
        self.maxLines = 0

    def start(self, surf, pos, size, color):
        self.pos = pos
        self.color = color
        self.surf = surf
        self.size = size
        print size
        self.maxLines = self.size[1]/15
        self.font = pygame.font.Font(None, 24)

    def stop(self):
        pass

    def update(self):
        if self.visible:
            pygame.draw.rect(self.surf, self.color, (self.pos[0], self.pos[1], self.size[0], self.size[1]), 3)
            cnt = 0
            for entry in self.lines:
                
                t = self.font.render(entry, 1, (0, 255, 0))
                self.surf.blit(t, (self.pos[0]+5, self.pos[1]+cnt*15+5))
                cnt = cnt + 1

    def addEntry(self, value):
        if len(self.lines) < self.maxLines:
            self.lines.append(value)
        else:
            del self.lines[0]
            self.lines.append(value)
        

class GUI:
    def __init__(self):
        self.widgets = {}
        self.eventHandler = None

    def start(self, e):
       self.eventHandler = e

    def update(self):
        for x in self.widgets:
            widget = self.widgets[x]
            widget.update()

    def addButton(self, name, surf, pos, text, command):
        self.widgets[name] = Button()
        self.widgets[name].start(surf, pos, text, self.eventHandler, command)

    def getWidget(self, name):
        return self.widgets[name]

    def addGraph(self, name, surf, pos, size, max_=200,  min_=0, width=100):
        self.widgets[name] = Graph()
        self.widgets[name].start(surf, pos, size, max_, min_, width)

    def addGraphChannel(self, name, chan, color):
        self.widgets[name].addChannel(chan, color)

    def addGraphEntry(self, name, chan, data):
        self.widgets[name].addChannelData(chan, data)

    def addLabel(self, name, surf, text, pos, color=(0,255,0), size=36):
        self.widgets[name] = Label()
        self.widgets[name].start(surf, pos, color, text, size)

    def addValueBox(self, name, surf, text, pos, color=(0,255,0), size=24, value=0):
        self.widgets[name] = ValueBox()
        self.widgets[name].start(surf, pos, color, text, size, value)

    def setValueBoxValue(self, name, value):
        self.widgets[name].setValue(value)
        

    def addCheckBox(self, name, surf, text, pos, color=(0,255,0), size=36, value=0):
        self.widgets[name] = CheckBox()
        self.widgets[name].start(surf, pos, color, text, self.eventHandler, size, value)

    def addTabBox(self, surf, pos, size):
        self.widgets[name] = Tab()
        self.widgets[name].start(surf, pos, size)

    def addCompass(self, name, surf, pos, radius):
        self.widgets[name] = Compass()
        self.widgets[name].start(surf, pos, radius)

    def setCompassAngle(self, name, angle):
        self.widgets[name].setAngle(angle)

    def addProgressBar(self, name, surf, pos, size, text=""):
        self.widgets[name] = ProgressBar()
        self.widgets[name].start(surf, pos, size, text)

    def setProgressBarValue(self, name, value):
        self.widgets[name].setValue(value)

    def addFrame(self, name, surf, text, pos, size, color):
        self.widgets[name] = Frame()
        self.widgets[name].start(surf, text, pos, size, color)

    def addQTIBWStrip(self, name, surf, pos, size):
        self.widgets[name] = QTIBWStrip()
        self.widgets[name].start(surf, pos, size)

    def setQTIBWStripValues(self, name, values):
        self.widgets[name].setValues(values)

    def addPictureBox(self, name, surf, text, pos, size, color, filename):
        self.widgets[name] = PictureBox()
        self.widgets[name].start(surf, text, pos, size, color, filename)

    def setPictureBoxImage(self, name, path):
        self.widgets[name].setImage(path)

    def getPictureBoxImage(self, name):
        return self.widgets[name].getImage()

    def addMap(self, name, surf, text, pos, size, color):
        self.widgets[name] = Map()
        self.widgets[name].start(surf, text, pos, size, color)

    def addTextBox(self, name, surf, pos, size, onEnterFunc):
        self.widgets[name] = TextBox()
        self.widgets[name].start(surf, pos, size, onEnterFunc)
        self.eventHandler.registerEvent(name+"KeydownEvent", pygame.KEYDOWN, self.widgets[name].onType)
        self.eventHandler.registerEvent(name+"ClickEvent", pygame.MOUSEBUTTONDOWN, self.widgets[name].onClick)

    def addTextListBox(self, name, surf, pos, size, color):
        self.widgets[name] = TextListBox()
        self.widgets[name].start(surf, pos, size, color)

    def addTextListBoxEntry(self, name, value):
        self.widgets[name].addEntry(value)
        
        
