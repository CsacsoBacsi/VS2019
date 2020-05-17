# --------------------------------------------------------------------

import threading
import time
import os
import queue

# --------------------------------------------------------------------

exitFlag = 0
class myThread (threading.Thread):
    shared_resource = 0
    def __init__(self, threadID, name, counter, delay, e):
        threading.Thread.__init__ (self) # Init the super class
        self.threadID = threadID
        self.name = name
        self.counter = counter
        self.delay = delay
        self.e = e
      
    def run (self): # Upon thread.start this function executes unless target = func and args = (1,2) specified. Func with args must be defined first
        print ("Starting " + self.name)
        print_thread_time (self.name, self.counter, self.delay)
        print ("Exiting " + self.name)
        self.e.wait () # Wait until the event is signalled
        print ("Woke up from event")
        self.e.clear ()

def print_thread_time (threadName, counter, delay):
    while counter:
        if exitFlag:
            threadName.exit()
        time.sleep (delay) # In seconds
        # Get lock to synchronize threads
        threadLock.acquire () # Otherwise print lines could get intermingled
        print ("Lock acquired: %s: %s" % (threadName, time.ctime (time.time ())))
        myThread.shared_resource += 1
        threadLock.release ()
        semaphore.acquire () # Otherwise print lines could get intermingled. Decreases semaphore count. Started from 1 so it is zero now. It blocks!
        print ("Semaphore acquired: %s: %s" % (threadName, time.ctime (time.time ())))
        myThread.shared_resource += 1
        semaphore.release () # Increases semaphore count
        counter -= 1

# Create new threads
e = threading.Event ()
thread1 = myThread (1, "Thread-1", 7, 1, e)
thread2 = myThread (2, "Thread-2", 5, 2, e) # Every two seconds

# Create lock
threadLock = threading.Lock () # To lock the resource
threads = [] # Thread list for the join operation at the end
threads.append (thread1)
threads.append (thread2)

# Create semaphore
semaphore = threading.Semaphore (value = 1) # Blocks if count is zero. That is why the param = 1

# Start new Threads
thread1.start()
time.sleep (0.0001) # Otherwise starting thread messages get intermingled
thread2.start()

print ("Main thread sleeps for 12 secs...")
time.sleep (12)
e.set () # Fires to the event moving the threads out of waiting
print ("Event set")

for t in threads: # Wait for threads before main exit
    t.join ()
print (myThread.shared_resource)
print ("Exiting Main Thread")

# --------------------------------------------------------------------

# Queues - Producer - Consumer
class myThreadQ (threading.Thread):
    shared_resource = 0
    def __init__(self, threadID, name, queue):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.queue = queue
      
    def run (self):
        print ("Starting " + self.name)
        process_data (self.name, self.queue)
        print ("Exiting " + self.name)

def process_data (threadName, queue):
    while not exitFlag:
        queueLock.acquire () # Lock the queue
        if not workQueue.empty ():
            data = queue.get () # Fetch an item from the queue
            print ("%s processing %s" % (threadName, data))
        queueLock.release () # Release queue lock 
    time.sleep (1)

threadList = ["Thread-1", "Thread-2", "Thread-3"]
itemList = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight"] # Queue items
queueLock = threading.Lock ()
workQueue = queue.Queue (10) # 10 is max size
threads = []
threadID = 1

for tName in threadList: # Kick off the threads
   thread = myThreadQ (threadID, tName, workQueue)
   thread.start()
   threads.append(thread)
   threadID += 1

# Fill the queue
queueLock.acquire ()
for word in itemList:
   workQueue.put (word) # Build a work-queue list
queueLock.release ()

# Wait for queue to empty
while not workQueue.empty ():
   pass

# Notify threads it's time to exit
exitFlag = 1 # Otherwise threads stay in an everlasting loop

# Wait for all threads to complete
for t in threads:
   t.join ()
print ("Exiting Main Thread")

# --------------------------------------------------------------------

os.system ("pause")
