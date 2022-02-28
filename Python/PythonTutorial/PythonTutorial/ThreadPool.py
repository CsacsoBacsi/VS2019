from time import sleep
from random import random
from random import randint
from concurrent.futures import ThreadPoolExecutor
import threading
import logging
from datetime import datetime

def task (name):
    now = datetime.now ()
    # print (now.strftime ("%d/%m/%Y %H:%M:%S") + ": Thread " + str (name) + " task: sleeps then increments")
    # sleep (randint (1, 3))
    sleep (2)
    inc (name)
    now = datetime.now ()
    return now.strftime ("%d/%m/%Y %H:%M:%S") + ": Worker " + str (name) + " finished task."

counter = 0
threadLock = threading.Lock ()

class myThread (threading.Thread):
    def __init__ (self, threadID, name, cnt):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.running = True
        global counter
        counter = cnt

    def run (self):
        print ("Starting worker " + str (self.name))
        while self.running:
            sleep (5)
            threadLock.acquire ()
            global counter
            counter = 0
            threadLock.release ()
            now = datetime.now ()
            if self.running:
                print (now.strftime ("%d/%m/%Y %H:%M:%S") + ": Authority: new permissions up for grabs.")

    def stop (self):
        self.running = False
        now = datetime.now ()
        print (now.strftime ("%d/%m/%Y %H:%M:%S") + ": Permission granting authority terminated.")
    
def inc (name):
    now = datetime.now ()
    print (now.strftime ("%d/%m/%Y %H:%M:%S") + ": Worker " + str (name) + " applied for permission to start")
    global counter
    while counter > 3:
        now = datetime.now ()
        print (now.strftime ("%d/%m/%Y %H:%M:%S") + ": Permissions exhausted, authority waits...")
        sleep (2)
    threadLock.acquire ()
    counter += 1
    threadLock.release ()
    now = datetime.now ()
    print (now.strftime ("%d/%m/%Y %H:%M:%S") + ": Worker " + str (name) + " permission granted. Permissions granted in total: " + str (counter))

auth = myThread (1, "Authority", 0)
auth.start ()


# Start the thread pool
with ThreadPoolExecutor (5) as executor:
    # execute 5 tasks concurrently
    for result in executor.map (task, range (1, 21, 1)):
        print (result)
    auth.stop ()