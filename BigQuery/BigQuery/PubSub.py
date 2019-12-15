# Standalone script to test Pub/Sub
from __future__ import absolute_import
from google.cloud import pubsub_v1

# Create topic first
publisher = pubsub_v1.PublisherClient () # Creates a publisher client
topic_name = 'projects/{project_id}/topics/{topic}'.format(project_id="famous-store-237108",topic="BQTopic")
topic_path = publisher.topic_path ("famous-store-237108", "BQTopic") # Creates a fully qualified topic path. Same as previous row

project_path = publisher.project_path("famous-store-237108") # Creates a fully qualified project path

found = False # Check if topic exists in project
for topic in publisher.list_topics (project_path): # topic is a fully qualified topic path
    if topic.name == topic_name:
        found = True
if not found: # If not found, create it
    publisher.create_topic (topic_name)

# Publish message. Please note since subscriber does not exist yet, this message is not going to be delivered
#future = publisher.publish (topic_name, b'My first message!', spam='this is spam') # Publish a message
#if future._completed: # Check if successful
#    print ("Message sent successfully!")

# Create subscriber
subscriber = pubsub_v1.SubscriberClient() # Creates a subscriber client
subscription_name = 'projects/{project_id}/subscriptions/{sub}'.format(project_id="famous-store-237108", sub="mysubscription")
subscription_path = subscriber.subscription_path ("famous-store-237108", "mysubscription") # Creates a fully qualified subscriber path

found = False # Check if subscription exists in project
for subscription in subscriber.list_subscriptions (project_path): # subscription is a fully qualified subscription path
    if subscription.name == subscription_name:
        found = True
if not found: # If not found, create it
    sub_instance = subscriber.create_subscription(name=subscription_name, topic=topic_name)

def callback (message): # Callback for subscriber futures. Basically a message handler
    print (message.data)
    message.ack () # Must notify queue that it has been processed

# Listen to messages. When receiving message, pass it on to callback function
future = subscriber.subscribe (subscription_path, callback = callback) # Subscribe subscriber for the topic

try:
    print ("Listening for messages from Matillion...\n")
    future.result () # This function blocks here. Keeps getting messages though!
except KeyboardInterrupt:
    future.cancel ()

