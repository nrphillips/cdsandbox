#!/usr/bin/env bash

source settings.sh

# ################################################################
# Uninstall spinnaker

hal deploy clean

kubectl config unset current-context
CONTEXT=$(kubectl config get-contexts -oname)
kubectl config delete-context $CONTEXT

KUBE_CLUSTER_FULLNAME=${SPINNAKER_INSTALL_CLUSTER}-${SPINNAKER_INSTALL_CLUSTER_VER}

# First get gcloud's default settings aligned with the project
gcloud config set compute/region ${SPINNAKER_INSTALL_CLUSTER_REGION}
gcloud config set compute/zone ${SPINNAKER_INSTALL_CLUSTER_ZONE}
gcloud config set container/use_client_certificate true
gcloud config set core/project ${SPINNAKER_INSTALL_PROJECT_NAME}

gcloud container clusters delete ${KUBE_CLUSTER_FULLNAME}

# Remove the storage bucket that spinnaker uses to maintain it's state.
gsutil rm -r gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}/
# Remove the service account that spinnaker uses to interact with GCS
GCS_ACCOUNT_EMAIL=${SPINNAKER_GCS_SERVICE_ACCOUNT}@${SPINNAKER_INSTALL_PROJECT_NAME}.iam.gserviceaccount.com
gcloud iam service-accounts delete ${GCS_ACCOUNT_EMAIL}

# TODO: Need to add something here that deletes the docker images
# from GCR.For now do this manually.
read -p "TODO: Need to add something here that deletes the docker images rom GCR.For now do this manually"

# Remove the docker repository
GCR_ACCOUNT_EMAIL=${SPINNAKER_GCR_SERVICE_ACCOUNT}@${SPINNAKER_INSTALL_PROJECT_NAME}.iam.gserviceaccount.com
gcloud iam service-accounts delete ${GCR_ACCOUNT_EMAIL}



hal config provider docker-registry account delete ${DOCKER_REGISTRY_ACCOUNT} --no-validate
hal config provider docker-registry disable

hal config provider kubernetes account delete ${KUBE_ACCOUNT_V1} --no-validate
hal config provider kubernetes disable

cp base-kube-config ~/.kube/config
cp base-hal-config ~/.hal/config


#CLUSTER=$(kubectl config get-clusters -oname)
#kubectl config delete-cluster $CLUSTER
# get-clusters doesn't have an -oname option
#kubectl config delete-cluster gke_nick-spinnaker_us-east1-b_nickstest-kube-cluster

#kubectl config unset users.gke_demoproject-dev-223314_us-east1-b_demoproject-dev-kube-cluster
#kubectl config unset users.gke_demoproject-dev2_us-east1-b_nickstest-kube-cluster
#kubectl config unset users.gke_nick-spin_us-east1-b_nickstest-kube-cluster
#
#DOCKER_REGISTRY_ACCOUNT=nicks-docker-registry
#GCE_ACCOUNT=nicks-gce-account
#KUBEV1_ACCOUNT=spin-k8s-v1-account
#KUBEV2_ACCOUNT=spin-k8s-v2-account

#hal config artifact gcs disable

# Delete any pubsubs if necessary
#KUBE_PUBSUB=my-google-pubsub
#hal config pubsub google subscription delete $KUBE_PUBSUB
#
#gcloud iam service-accounts delete spin-gce-account@nick-spinnaker.iam.gserviceaccount.com
#gcloud iam service-accounts delete spin-gcr-account@nick-spinnaker.iam.gserviceaccount.com
#gcloud iam service-accounts delete spin-gcs-account@nick-spinnaker.iam.gserviceaccount.com
#gcloud iam service-accounts delete spin-gcs-artifacts-account@nick-spinnaker.iam.gserviceaccount.com
