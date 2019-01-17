## ######################################################################################
## Support for triggering pipelines based on a docker file
## ######################################################################################

## Set up a spinnaker provider for the Google Container Registry.
# https://www.spinnaker.io/setup/install/providers/docker-registry/#google-container-registry
#
ADDRESS=gcr.io

## Set up a service account so that spinnaker can access the Google Container Registry
SERVICE_ACCOUNT_NAME=spinnaker-gcr-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/browser

gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/storage.admin

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL

PASSWORD_FILE=$SERVICE_ACCOUNT_DEST

# Enable the docker-registry provider
hal config provider docker-registry enable

# Add the registry provider to spinnaker
hal config provider docker-registry account add my-docker-registry \
 --address $ADDRESS \
 --username _json_key \
 --password-file $PASSWORD_FILE \

# And update the registry with my docker repository, this can be found at
# https://console.cloud.google.com/gcr/images/demoproject-dev2 (or whatever project you're in)
# and note that it has to contain both the project and repository name. Theoretically spinnaker can
# pick this up with having to add the repository explicitly, but I found that to not be the case so
# I had to add it by hand. 
REPOSITORY=demoproject-dev2/demoservice
hal config provider docker-registry account edit my-docker-registry --add-repository $REPOSITORY

