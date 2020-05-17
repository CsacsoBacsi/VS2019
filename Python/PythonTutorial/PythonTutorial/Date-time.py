# --------------------------------------------------------------------

import os
from datetime import timedelta, datetime
import time

# --------------------------------------------------------------------

start_date = datetime.strptime ('2018-01-01', '%Y-%m-%d')
end_date = datetime.strptime ('2018-01-31', '%Y-%m-%d')
print ("From " + str (start_date) + " to: " + str (end_date))

def daterange (start_date, end_date): # Generator
    for n in range (int ((end_date - start_date).days)):
        yield start_date + timedelta (n)

for single_date in daterange (start_date, end_date):
    print (single_date.strftime ("%Y-%m-%d"))

print ("time.time_ns(): %s" % time.time_ns ()) # Time in nano-seconds since epoch (1970)
print ("time.time(): %s" % time.time ())

#printf (str (time.clock_gettime_ns(clock_id)))
#printf (str (time.monotonic_ns()))

print ("time.perf_counter_ns(): %s" % time.perf_counter_ns()) # Does not mean anything. Only after some time elapsed. The difference
print ("time.process_time_ns(): %s" % time.process_time_ns())
time.sleep(1)
print ("time.process_time_ns(): %s" % time.process_time_ns())

time_before = time.time_ns ()
time.sleep (1)
time_after = time.time_ns ()
print ("Diff: ", time_after - time_before)

# --------------------------------------------------------------------

os.system ("pause")


