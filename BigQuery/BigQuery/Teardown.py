# Standalone script to teardown dataset 9and with it the table9, the Pub/Sub topic and the subscribers
# This was necessary to enable the repetition of the Oracle -> Pub/Sub -> Dataflow -> BigQuery example
# Otherwise streamed data in the target table ca n not be deleted for up to 90 mins
# So we rather obliterate everything and set up again with the Setup.py script 
from google.cloud import pubsub_v1
from google.cloud import bigquery

# Constants
PROJECT    = "famous-store-237108"
TOPIC      = "BQTopic"
TOPIC_NAME = 'projects/{project_id}/topics/{topic}'.format (project_id = PROJECT, topic = TOPIC)
DATASET    = "HR_dataset"

# Delete BQTopic topic
publisher = pubsub_v1.PublisherClient () # Creates a publisher client
topic_path = publisher.topic_path (PROJECT, TOPIC) # Creates a fully qualified topic path. Same as previous row

project_path = publisher.project_path(PROJECT) # Creates a fully qualified project path

for topic in publisher.list_topics (project_path): # topic is a fully qualified topic path
    if topic.name == TOPIC_NAME:
        publisher.delete_topic (topic_path)
        print('Topic deleted: {}'.format (topic_path))

# Delete all subscribers
subscriber = pubsub_v1.SubscriberClient () # Creates a subscriber client
subscription_name = 'projects/{project_id}/subscriptions/{sub}'.format (project_id="famous-store-237108", sub="mysubscription")
subscription_path = subscriber.subscription_path ("famous-store-237108", "mysubscription") # Creates a fully qualified subscriber path

for subscription in subscriber.list_subscriptions (project_path): # subscription is a fully qualified subscription path
    subscriber.delete_subscription (subscription.name)
    print ('Subscription deleted: {}'.format (subscription.name))

# Obliterate dataset (including all the tables in it)
client = bigquery.Client ()

dataset_id = ("{}." + DATASET).format (client.project)

datasets = list (client.list_datasets ())
project = client.project

if datasets:
    for dataset in datasets:
        if dataset.dataset_id == DATASET:
            client.delete_dataset (dataset_id, delete_contents = True, not_found_ok = True)
            print ("Deleted dataset {}.".format (dataset.dataset_id))
else:
    print ("{} project does not contain any datasets.".format(project))

print ("Topic, subscriptions, dataset (inncluding the target table) have all been obliterated")