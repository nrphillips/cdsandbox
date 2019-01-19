#!/usr/bin/env bash

#source settings.sh

## ######################################################################################
## Grant Spinnaker permissions to GCS (Google Cloud Storage)
## Spinnaker requires an external storage provider for persisting application settings and
## configured pipelines. Because these data are sensitive and can be costly to lose, we recommend
## you use a hosted storage solution you are confident in.

# Create a bucket to hold spinnaker assets
gsutil mb gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}/

# Create related service account
gcloud iam service-accounts create \
    ${SPINNAKER_GCS_SERVICE_ACCOUNT} \
    --display-name ${SPINNAKER_GCS_SERVICE_ACCOUNT}

GCS_SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SPINNAKER_GCS_SERVICE_ACCOUNT" \
    --format='value(email)')

#PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding ${SPINNAKER_INSTALL_PROJECT_NAME} \
    --role roles/storage.admin --member serviceAccount:${GCS_SA_EMAIL}

mkdir -p $(dirname ${SPINNAKER_GCS_SERVICE_ACCOUNT_DEST})

gcloud iam service-accounts keys create ${SPINNAKER_GCS_SERVICE_ACCOUNT_DEST} \
    --iam-account ${GCS_SA_EMAIL}

# grant permissions on the bucket to the service account
gsutil iam ch serviceAccount:${GCS_SA_EMAIL}:roles/storage.admin gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}

# Tell spinnaker that we're using the specified gcs bucket.
hal config storage edit --type gcs --no-validate
hal config storage gcs edit --bucket ${SPINNAKER_INSTALL_GCSBUCKET_NAME}
hal config storage gcs edit --bucket-location ${SPINNAKER_INSTALL_GCSBUCKET_LOCATION}

