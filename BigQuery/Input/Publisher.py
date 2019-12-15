from __future__ import absolute_import
from google.cloud import pubsub_v1
import time
import sys
import OracleSource as ora

# Constants
PROJECT = "famous-store-237108"
TOPIC   = "BQTopic"
TOPIC_NAME = 'projects/{project_id}/topics/{topic}'.format (project_id = PROJECT, topic = TOPIC)

def printf (format, *args):
  sys.stdout.write (format % args)

class publisher:
    client = pubsub_v1.PublisherClient () # Creates a publisher client

    def publish (self, ora, wait_in_sec):
        i = 0
        for rows in ora.fetchResult (): # Streams require byte stream, hence first needs to convert to string then bytes
            time.sleep (wait_in_sec)
            str_row = ''
            for row in rows:
                str_row = str_row + ''.join (str (row) + ',')
            str_row = str_row [0:len (str_row)-1]
            byte_row = bytes (str_row, 'utf-8')
            future = publisher.client.publish (TOPIC_NAME, byte_row) # Publish a message
            printf (str_row)
            printf ("\n")
    
            if future._completed: # Check if successful
                i = i + 1
                printf ("Message %d sent successfully!\n", i)
 
def main ():
    myOra = ora.Oracle ()
    retval = myOra.openConnection ()
    retval = myOra.openCursor ()
    
    pub = publisher ()
    time.sleep (5) # Wait for Apache Beam (Dataflow) to spin up
    pub.publish (myOra, 1.5)

if __name__ == '__main__':
    main ()