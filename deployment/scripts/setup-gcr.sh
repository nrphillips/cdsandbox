#!/usr/bin/env bash

#source settings.sh

## ######################################################################################
## Support for docker images
## ######################################################################################

## Set up a spinnaker provider for the Google Container Registry.
# https://www.spinnaker.io/setup/install/providers/docker-registry/#google-container-registry
#
##DOCKER_REGISTRY_ADDRESS=gcr.io
##REGISTRY_ACCOUNT=nicks-docker-registry

## Set up a service account so that spinnaker can access the Google Container Registry
#SERVICE_ACCOUNT_NAME=spinnaker-gcr-account
#SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json

gcloud iam service-accounts create -q \
    ${SPINNAKER_GCR_SERVICE_ACCOUNT} \
    --display-name ${SPINNAKER_GCR_SERVICE_ACCOUNT}

#GCR_SA_EMAIL=$(gcloud iam service-accounts list \
#    --filter="displayName:${SPINNAKER_GCR_SERVICE_ACCOUNT}" \
#    --format='value(email)')
#
#PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding ${SPINNAKER_INSTALL_PROJECT_NAME} --role roles/browser \
    --member serviceAccount:${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}
gcloud projects add-iam-policy-binding ${SPINNAKER_INSTALL_PROJECT_NAME} --role roles/storage.admin \
    --member serviceAccount:${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}

mkdir -p $(dirname ${SPINNAKER_GCR_SERVICE_ACCOUNT_DEST})

gcloud iam service-accounts keys create -q ${SPINNAKER_GCR_SERVICE_ACCOUNT_DEST} \
    --iam-account ${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}

# grant permissions on the bucket to the service account
#gsutil iam ch serviceAccount:${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}:roles/storage.admin gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}
