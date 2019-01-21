#!/usr/bin/env bash

# Set this to the relevant spinnaker version. I think we can put "latest" in here.
SPINNAKER_VERSION=1.10.11

# GCP Project Name - This must exist before running the script
SPINNAKER_INSTALL_PROJECT_NAME=np-beta
SPINNAKER_INSTALL_PROJECT_SA_DOMAIN=${SPINNAKER_INSTALL_PROJECT_NAME}.iam.gserviceaccount.com

# This is the kubernetes cluster where spinnaker will be installed. Ensure that it DOES NOT exist
# prior to running scripts/setup-cluster.sh
SPINNAKER_INSTALL_CLUSTER=np
SPINNAKER_INSTALL_CLUSTER_VER=dev
SPINNAKER_INSTALL_CLUSTER_FULLNAME=${SPINNAKER_INSTALL_CLUSTER}-${SPINNAKER_INSTALL_CLUSTER_VER}

# Cluster region/zone information
SPINNAKER_INSTALL_CLUSTER_REGION=us-east1
SPINNAKER_INSTALL_CLUSTER_ZONE=us-east1-b

# Google Cloud Storage (GCS) bucket that holds spinnaker internal objects.
# NOTE: SPINNAKER_INSTALL_GCSBUCKET_NAME must be unique across THE ENTIRE GCS NAMESPACE!
SPINNAKER_INSTALL_GCSBUCKET_LOCATION=us
SPINNAKER_INSTALL_GCSBUCKET_NAME=nrp0110-spin-data

# gcloud account that spinnaker uses to access GCS
SPINNAKER_GCS_SERVICE_ACCOUNT=spin-gcs-account
SPINNAKER_GCS_SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json
SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL=${SPINNAKER_GCS_SERVICE_ACCOUNT}@${SPINNAKER_INSTALL_PROJECT_SA_DOMAIN}

# gcloud account that spinnaker uses to access GCR
SPINNAKER_GCR_SERVICE_ACCOUNT=spin-gcr-account
SPINNAKER_GCR_SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json
SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL=${SPINNAKER_GCR_SERVICE_ACCOUNT}@${SPINNAKER_INSTALL_PROJECT_SA_DOMAIN}

DOCKER_REGISTRY_ADDRESS=gcr.io
DOCKER_REGISTRY_ACCOUNT=nicks-docker-registry
DOCKER_REPOSITORY=${SPINNAKER_INSTALL_PROJECT_NAME}/demoservice

KUBE_ACCOUNT_V1=spin-k8s-v1-account
KUBE_ACCOUNT_V2=spin-k8s-v2-account
#KUBE_CONTEXT=gke_np-alpha_us-east1-b_np-dev
KUBE_CONTEXT=gke_${SPINNAKER_INSTALL_PROJECT_NAME}_${SPINNAKER_INSTALL_CLUSTER_ZONE}_${SPINNAKER_INSTALL_CLUSTER}-${SPINNAKER_INSTALL_CLUSTER_VER}
