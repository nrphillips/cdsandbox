#!/usr/bin/env bash

#source settings.sh

## ######################################################################################################
## Grant Spinnaker permissions to GCS (Google Cloud Storage)
## Spinnaker requires an external storage provider for persisting application settings and
## configured pipelines. Because these data are sensitive and can be costly to lose, we recommend
## you use a hosted storage solution you are confident in.

# Create a bucket to hold spinnaker assets
gsutil mb gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}/

# Create related service account
gcloud iam service-accounts create -q \
    ${SPINNAKER_GCS_SERVICE_ACCOUNT} \
    --display-name ${SPINNAKER_GCS_SERVICE_ACCOUNT}

#GCS_SA_EMAIL=$(gcloud iam service-accounts list \
#    --filter="displayName:$SPINNAKER_GCS_SERVICE_ACCOUNT" \
#    --format='value(email)')
#
##PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding -q ${SPINNAKER_INSTALL_PROJECT_NAME} \
    --role roles/storage.admin --member serviceAccount:${SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL}

mkdir -p $(dirname ${SPINNAKER_GCS_SERVICE_ACCOUNT_DEST})

gcloud iam service-accounts keys create ${SPINNAKER_GCS_SERVICE_ACCOUNT_DEST} \
    --iam-account ${SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL}

# grant permissions on the bucket to the service account
gsutil iam ch serviceAccount:${SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL}:roles/storage.admin gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}

# Tell spinnaker that we're using the specified gcs bucket.
hal config storage gcs edit --project ${SPINNAKER_INSTALL_PROJECT_NAME} \
    --bucket ${SPINNAKER_INSTALL_GCSBUCKET_NAME} \
    --bucket-location ${SPINNAKER_INSTALL_GCSBUCKET_LOCATION} \
    --json-path ${SPINNAKER_GCS_SERVICE_ACCOUNT_DEST}

hal config storage edit --type gcs
