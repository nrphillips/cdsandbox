#!/usr/bin/env bash

# Set this to the relevant spinnaker version. I think we can put "latest" in here.
SPINNAKER_VERSION=1.10.11

# Set this prior to running the install
SPINNAKER_INSTALL_TYPE=kube-v1

# GCP Project Name - This must exist before running the script
SPINNAKER_INSTALL_PROJECT_NAME=np-alpha

# This is the kubernetes cluster where spinnaker will be installed. Ensure that it DOES NOT exist
# prior to running 1-Cluster_Setup.sh
SPINNAKER_INSTALL_CLUSTER=np
SPINNAKER_INSTALL_CLUSTER_VER=dev
SPINNAKER_INSTALL_CLUSTER_FULLNAME=${SPINNAKER_INSTALL_CLUSTER}-${SPINNAKER_INSTALL_CLUSTER_VER}

# Cluster region/zone information
SPINNAKER_INSTALL_CLUSTER_REGION=us-east1
SPINNAKER_INSTALL_CLUSTER_ZONE=us-east1-b

# Google Cloud Storage (GCS) bucket that holds spinnaker internal objects.
# NOTE: SPINNAKER_INSTALL_GCSBUCKET_NAME must be unique across THE ENTIRE GCS NAMESPACE!
SPINNAKER_INSTALL_GCSBUCKET_LOCATION=us
SPINNAKER_INSTALL_GCSBUCKET_NAME=nrp0110-spin-objects

# gcloud account that spinnaker uses to access GCS
SPINNAKER_GCS_SERVICE_ACCOUNT=spin-gcs-account
SPINNAKER_GCS_SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json

# gcloud account that spinnaker uses to access GCR
SPINNAKER_GCR_SERVICE_ACCOUNT=spin-gcr-account
SPINNAKER_GCR_SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json

DOCKER_REGISTRY_ADDRESS=gcr.io
DOCKER_REGISTRY_ACCOUNT=nicks-docker-registry
DOCKER_REPOSITORY=${SPINNAKER_INSTALL_PROJECT_NAME}/demoservice

KUBE_ACCOUNT_V1=spin-k8s-v1-account
KUBE_ACCOUNT_V2=spin-k8s-v2-account
#KUBE_CONTEXT=gke_np-alpha_us-east1-b_np-dev
KUBE_CONTEXT=gke_${SPINNAKER_INSTALL_PROJECT_NAME}_${SPINNAKER_INSTALL_CLUSTER_ZONE}_${SPINNAKER_INSTALL_CLUSTER}-${SPINNAKER_INSTALL_CLUSTER_VER}


#
#
#
#
#
#
#
#PROJECT_NAME=nick-spinnaker
#SPINNAKER_INSTALL_CLUSTER_NAME=nickstest
#SPINNAKER_INSTALL_CLUSTER_REGION=us-east1
#SPINNAKER_INSTALL_CLUSTER_ZONE=us-east1-b
#SPINNAKER_INSTALL_CLUSTER_VER=dev
#SPINNAKER_INSTALL_CLUSTER_FULLNAME=$SPINNAKER_INSTALL_CLUSTER_NAME-$SPINNAKER_INSTALL_CLUSTER_VER
#
## First get gcloud's default sett
# ings aligned with the project
#gcloud config set compute/region $SPINNAKER_INSTALL_CLUSTER_REGION
#gcloud config set compute/zone $SPINNAKER_INSTALL_CLUSTER_ZONE
#gcloud config set container/use_client_certificate true
#gcloud config set core/project $PROJECT_NAME
#
## Review these config values for stale configurations, they may as well be removed
## if they're not in use. You can remove them via "kubectl config delete-cluster" and
## kubectl config delete-context"
#
#kubectl config get-clusters
#kubectl config get-contexts
#
### ######################################################################################
### In this setup we're going to run Spinnaker on a kubernetes cluster
### ######################################################################################
#
### Set up the GKE cluster that will host Spinaker
#
## Note: The "Small" cluster version (and presumably cheaper) is
## --machine-type=g1-small,
## --cluster-version=1.11.5-gke.5
## --num-nodes=1
#
## When I didn't use at least --num-nodes=2 --machine-type=n1-standard-2 the gcp console was indicating that I didn't
## have enough resources to run all of the spinnaker processes (igor, rosco, etc)
#
#gcloud container clusters create $SPINNAKER_INSTALL_CLUSTER_FULLNAME \
#    --enable-legacy-authorization --num-nodes=2 --machine-type=n1-standard-2 --cluster-version=latest
#
## Note that the spinnaker documentation says that this needs to be done
##gcloud container clusters update $SPINNAKER_INSTALL_CLUSTER_NAME-kube-cluster-kube-cluster --enable-legacy-authorization
#
#gcloud container clusters get-credentials $SPINNAKER_INSTALL_CLUSTER_FULLNAME --zone $SPINNAKER_INSTALL_CLUSTER_ZONE --project $PROJECT_NAME
#
### Set up Spinnaker to use Kubernetes
#
## ensure kubernetes provider is enabled
#hal config provider kubernetes enable
#
## Add account
#KUBEV2_CONTEXT=$(kubectl config current-context)
#KUBEV2_ACCOUNT=spin-k8s-v2-account
#
#hal config provider kubernetes account add $KUBEV2_ACCOUNT \
#    --provider-version v2 \
#    --context $KUBE_CONTEXT
#
## Not sure why this is necessary.
#hal config features edit --artifacts true
#
### Install Spinnaker on Kubernetes
#hal config deploy edit --type distributed --account-name $KUBEV2_ACCOUNT
#
## Need to bounce halyard by shutting down then issuing any hal command
#hal shutdown
#hal --version
#
### ######################################################################################
### Grant Spinnaker permissions to GCS (Google Cloud Storage)
### Spinnaker requires an external storage provider for persisting application settings and
### configured pipelines. Because these data are sensitive and can be costly to lose, we recommend
### you use a hosted storage solution you are confident in.
#
## Create a bucket to hold spinnaker assets
#BUCKET_LOCATION=us
#BUCKET_NAME=nrp0110-spin-test
#gsutil mb gs://$BUCKET_NAME/
#
## Create service account
#SERVICE_ACCOUNT_NAME=spin-gcs-account
#SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json
#
#gcloud iam service-accounts create \
#    $SERVICE_ACCOUNT_NAME \
#    --display-name $SERVICE_ACCOUNT_NAME
#
#SA_EMAIL=$(gcloud iam service-accounts list \
#    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
#    --format='value(email)')
#
#PROJECT=$(gcloud info --format='value(config.project)')
#
#gcloud projects add-iam-policy-binding $PROJECT \
#    --role roles/storage.admin --member serviceAccount:$SA_EMAIL
#
#mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)
#
#gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
#    --iam-account $SA_EMAIL
#
## grant permissions on the bucket to the service account
#gsutil iam ch serviceAccount:$SA_EMAIL:roles/storage.admin gs://$BUCKET_NAME
#hal config storage gcs edit --bucket $BUCKET_NAME
#
### PROJECT=$(gcloud info --format='value(config.project)')
## see https://cloud.google.com/storage/docs/bucket-locations
#
## NOTE: hal config retains bucket information from any prior installs. Which causes an
## error when you try to redeploy. It may be possible to "NULL" out the gcs config
## by editing ~/.hal/config directly, I know I wasn't able to do it by going
## hal config storage gcs edit -no-validate --bucket null
## so I had to find the bucket name from my new projects gcs list and edit it via
## hal config storage gcs edit -no-validate --bucket spin-85698550-ac2f-4513-96cd-2f7b0483e2e1
## this might need to be "fixed" in cases where we're tearing down and reinstalling spinnaker
## from the same hal installation.
#
#hal config storage gcs edit --project $PROJECT \
#    --bucket-location $BUCKET_LOCATION \
#    --json-path $SERVICE_ACCOUNT_DEST
#
#hal config storage edit --type gcs
#
### ######################################################################################
### Now deploy spinnaker
#
## This might need to be done manually because you need to select a version
## that's available from this list.
## hal version list
#SPINNAKER_VERSION=1.10.11
#hal config version edit --version $SPINNAKER_VERSION
#
#hal deploy apply
#
