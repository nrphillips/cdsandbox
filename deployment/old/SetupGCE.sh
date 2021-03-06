#!/usr/bin/env bash
## ######################################################################################
## As far as I can tell, I need to enable the google provider through hal
## if I want to drive the spinnaker UI in the way that any of the demos
## suggest.
## ######################################################################################

SERVICE_ACCOUNT_NAME=spin-gce-account
SERVICE_ACCOUNT_DEST=~/.gcp/gce-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

# permission to create/modify instances in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.instanceAdmin

# permission to create/modify network settings in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.networkAdmin

# permission to create/modify firewall rules in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.securityAdmin

# permission to create/modify images & disks in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.storageAdmin

# permission to download service account keys in your project
# this is needed by packer to bake GCE images remotely
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/iam.serviceAccountActor

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL

hal config provider google enable

GCE_ACCOUNT=nicks-gce-account
hal config provider google account add $GCE_ACCOUNT --project $PROJECT \
    --json-path $SERVICE_ACCOUNT_DEST
