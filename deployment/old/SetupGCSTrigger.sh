# https://www.spinnaker.io/guides/user/pipeline/triggers/gcs/

# Setting up GCS Pub-Sub
# https://www.spinnaker.io/setup/triggers/google/


# https://console.cloud.google.com/storage/browser
BUCKET=artifacts.demoproject-dev2.appspot.com
TOPIC=demoproject-topic
SUBSCRIPTION=demoproject-sub
PROJECT=demoproject-dev2
MESSAGE_FORMAT=GCS

# Create a notification for changes to the project's GCS bucket.
gsutil notification create -t $TOPIC -f json gs://$BUCKET

# Create a subscription
gcloud beta pubsub subscriptions create $SUBSCRIPTION --topic $TOPIC

# Spinnaker needs a service account to authenticate as against GCP, with the roles/pubsub.subscriber role enabled.
SERVICE_ACCOUNT_NAME=spinnaker-pubsub-account
SERVICE_ACCOUNT_DEST=~/.gcp/pubsub-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL


# This will be the name of the subscription in spinnaker
PUBSUB_NAME=my-google-pubsub

# Now subscribe to the subscription that was created above
hal config pubsub google subscription add $PUBSUB_NAME \
    --subscription-name $SUBSCRIPTION \
    --json-path $SERVICE_ACCOUNT_DEST \
    --project $PROJECT \
    --message-format $MESSAGE_FORMAT


