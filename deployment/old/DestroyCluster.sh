#!/usr/bin/env bash

# ################################################################
# Uninstall spinnaker

hal deploy clean

kubectl config unset current-context
CONTEXT=$(kubectl config get-contexts -oname)
kubectl config delete-context $CONTEXT

PROJECT_NAME=nick-spinnaker
KUBE_CLUSTER_NAME=nickstest
KUBE_CLUSTER_REGION=us-east1
KUBE_CLUSTER_ZONE=us-east1-b
KUBE_CLUSTER_VER=dev
KUBE_CLUSTER_FULLNAME=$KUBE_CLUSTER_NAME-$KUBE_CLUSTER_VER
BUCKET_NAME=nrp0110-spin-test

# First get gcloud's default settings aligned with the project
gcloud config set compute/region $KUBE_CLUSTER_REGION
gcloud config set compute/zone $KUBE_CLUSTER_ZONE
gcloud config set container/use_client_certificate true
gcloud config set core/project $PROJECT_NAME

gcloud container clusters delete $KUBE_CLUSTER_FULLNAME

# These remove cloud storage buckets
#gsutil rm gs://artifacts.nick-spinnaker.appspot.com/
gsutil rm -r gs://$BUCKET_NAME/

SERVICE_ACCOUNT_NAME=spin-gcs-account
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

gcloud iam service-accounts delete $SA_EMAIL

#CLUSTER=$(kubectl config get-clusters -oname)
#kubectl config delete-cluster $CLUSTER
# get-clusters doesn't have an -oname option
#kubectl config delete-cluster gke_nick-spinnaker_us-east1-b_nickstest-kube-cluster

kubectl config unset users.gke_demoproject-dev-223314_us-east1-b_demoproject-dev-kube-cluster
kubectl config unset users.gke_demoproject-dev2_us-east1-b_nickstest-kube-cluster
kubectl config unset users.gke_nick-spin_us-east1-b_nickstest-kube-cluster

DOCKER_REGISTRY_ACCOUNT=nicks-docker-registry
GCE_ACCOUNT=nicks-gce-account
KUBEV1_ACCOUNT=spin-k8s-v1-account
KUBEV2_ACCOUNT=spin-k8s-v2-account

hal config provider docker-registry account delete $DOCKER_REGISTRY_ACCOUNT --no-validate
hal config provider docker-registry disable
hal config provider google account delete $GCE_ACCOUNT --no-validate
hal config provider google disable
hal config provider kubernetes account delete $KUBEV1_ACCOUNT --no-validate
hal config provider kubernetes account delete $KUBEV2_ACCOUNT --no-validate
hal config provider kubernetes disable
hal config artifact gcs disable

# Delete any pubsubs if necessary
#KUBE_PUBSUB=my-google-pubsub
#hal config pubsub google subscription delete $KUBE_PUBSUB

gcloud iam service-accounts delete spin-gce-account@nick-spinnaker.iam.gserviceaccount.com
gcloud iam service-accounts delete spin-gcr-account@nick-spinnaker.iam.gserviceaccount.com
gcloud iam service-accounts delete spin-gcs-account@nick-spinnaker.iam.gserviceaccount.com
gcloud iam service-accounts delete spin-gcs-artifacts-account@nick-spinnaker.iam.gserviceaccount.com
