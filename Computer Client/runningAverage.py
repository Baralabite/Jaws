count = 0
total = 0
average = 0

def add(value):
    global count, total, average
    count =  count + 1
    total = total + value
    average = total/count
    return average

def get():
    return average
