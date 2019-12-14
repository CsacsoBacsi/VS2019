#!/usr/bin/env python
import threading as th
import logging, time
import multiprocessing

from kafka import KafkaConsumer, KafkaProducer

class Producer(th.Thread): # Derives from Threading
    def __init__(self):
        th.Thread.__init__(self)
        self.stop_event = th.Event () # Create event

    def stop (self):
        self.stop_event.set () # Trigger event, set to True

    def run (self): # Thread start will invoke this
        producer = KafkaProducer (bootstrap_servers='localhost:9092', api_version=(0, 10))

        while not self.stop_event.is_set():
            producer.send (b'mytopic', b"test")
            producer.send (b'mytopic', b"Hola, mundo!")

            time.sleep (2) # Do it once in every second

        producer.close () # Stop producing

class Consumer (multiprocessing.Process):
    def __init__(self):
        multiprocessing.Process.__init__(self)
        self.stop_event = multiprocessing.Event()
       
    def stop (self):
        self.stop_event.set ()
    
    def run (self):
        consumer = KafkaConsumer (bootstrap_servers='127.0.0.1:9092',
                                  auto_offset_reset='earliest',
                                  consumer_timeout_ms=1000,
                                  api_version=(0, 10))

        consumer.subscribe ([b'mytopic']) # Could be multiple
        while not self.stop_event.is_set ():
            for message in consumer:
                print (message)
                if self.stop_event.is_set():
                    break

        consumer.close ()

def main():
    tasks = [
        Producer(),
        
    ]

    for t in tasks:
        t.start()

    time.sleep(20)

    for task in tasks:
        task.stop()

    for task in tasks:
        task.join()

if __name__ == "__main__":
    logging.basicConfig(
        format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
        level=logging.INFO
        )
    main ()
