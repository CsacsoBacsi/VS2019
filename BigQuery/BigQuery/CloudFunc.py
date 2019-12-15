from google.cloud import pubsub_v1

PROJECT    = "famous-store-237108"
TOPIC      = "MatillionEvents"

def GCSFileTrigger (data, context):
    """Background Cloud Function to be triggered by Cloud Storage.
       This generic function logs relevant data when a file is changed.

    Args:
        data (dict): The Cloud Functions event payload.
        context (google.cloud.functions.Context): Metadata of triggering event.
    Returns:
        None; the output is written to Stackdriver Logging
    """

    # This goes to the log
    print('Event ID: {}'.format(context.event_id))
    print('Event type: {}'.format(context.event_type))
    print('Bucket: {}'.format(data['bucket']))
    print('File: {}'.format(data['name']))
    print('Metageneration: {}'.format(data['metageneration']))
    print('Created: {}'.format(data['timeCreated']))
    print('Updated: {}'.format(data['updated']))

# ********************************************* Matillion ***********************************************
    msg = b'{"group":"MyCompany", "project":"TestDrive1", "version":"default", "environment":"MyEnv", "job":"UDM2Consumption","variables":{"Var1": "Val1", "Var2": "Val2>"}}'

    publisher = pubsub_v1.PublisherClient () # Creates a publisher client
    topic_name = 'projects/{project_id}/topics/{topic}'.format (project_id = PROJECT, topic = TOPIC)

    # Publish message. Please note since subscriber does not exist yet, this message is not going to be delivered
    future = publisher.publish (topic_name, msg) # Publish a message
    if future._completed: # Check if successful
        print ("Message to Matillion sent successfully!")
        
