## In order to setup Spinnaker, first you need a kube cluster and credentials

PROJECT_NAME=demoproject-dev2
KUBE_CLUSTER_NAME=nickstest
KUBE_CLUSTER_ZONE=us-east1-b

## ######################################################################################
## In this setup we're going to run Spinnaker on a kubernetes cluster
## ######################################################################################

## Set up the GKE cluster that will host Spinaker

# Note: The "Small" cluster version (and presumably cheaper) is
# --machine-type=g1-small,
# --cluster-version=1.11.5-gke.5
# --num-nodes=1

# When I didn't use at least --num-nodes=2 --machine-type=n1-standard-2 the gcp console was indicating that I didn't
# have enough resources to run all of the spinnaker processes (igor, rosco, etc)

gcloud container clusters create $KUBE_CLUSTER_NAME-kube-cluster --zone=$KUBE_CLUSTER_ZONE \
    --enable-legacy-authorization --num-nodes=4 --machine-type=n1-standard-2 --cluster-version=latest

#
#gcloud container clusters update $KUBE_CLUSTER_NAME-kube-cluster-kube-cluster --enable-legacy-authorization

gcloud container clusters get-credentials $KUBE_CLUSTER_NAME-kube-cluster --zone $KUBE_CLUSTER_ZONE --project $PROJECT_NAME

## Set up Spinnaker to use Kubernetes

# ensure kubernetes provider is enabled
hal config provider kubernetes enable

# Add account
CONTEXT=$(kubectl config current-context)
ACCOUNT=my-k8s-v2-account

hal config provider kubernetes account add $ACCOUNT \
    --provider-version v2 \
    --context $CONTEXT

# Not sure why this is necessary.
hal config features edit --artifacts true

## Install Spinnaker on Kubernetes
hal config deploy edit --type distributed --account-name $ACCOUNT

# Need to bounce halyard by shutting down then issuing any hal command
hal shutdown
hal --version

## ######################################################################################
## Grant Spinnaker permissions to GCS (Google Cloud Storage)
## Spinnaker requires an external storage provider for persisting application settings and
## configured pipelines. Because these data are sensitive and can be costly to lose, we recommend
## you use a hosted storage solution you are confident in.

SERVICE_ACCOUNT_NAME=spinnaker-gcs-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin --member serviceAccount:$SA_EMAIL

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL

## PROJECT=$(gcloud info --format='value(config.project)')
# see https://cloud.google.com/storage/docs/bucket-locations
BUCKET_LOCATION=us

hal config storage gcs edit --project $PROJECT \
    --bucket-location $BUCKET_LOCATION \
    --json-path $SERVICE_ACCOUNT_DEST

hal config storage edit --type gcs

## ######################################################################################
## Now deploy spinnaker

# This might need to be done manually because you need to select a version
# that's available from this list.
# hal version list
SPINNAKER_VERSION=1.11.5
hal config version edit --version $SPINNAKER_VERSION

hal deploy apply

