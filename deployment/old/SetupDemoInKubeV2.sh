#!/usr/bin/env bash
## ######################################################################################
## A script that does the stuff in:
## https://www.spinnaker.io/guides/tutorials/codelabs/kubernetes-v2-source-to-prod/
## ######################################################################################

# In order to set up kubernetes I'm following the script in SetupClusterKubeV2.sh

# Note: I haven't tried this when it returns two contexts yet!
STAGING_CONTEXT=$(kubectl config get-contexts -oname)
DEMO_ACCOUNT=nicks-staging-demo

#hal config provider kubernetes account add prod-demo \
#  --context $PROD_CONTEXT \
#  --provider-version v2


## The demo wants us to use GitHub to store the "artifact" that contains the
## manifest. But I'm going to use gcs for this iteration
# here's how you set this up. https://www.spinnaker.io/setup/artifacts/gcs/
SERVICE_ACCOUNT_NAME=spin-gcs-artifacts-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-artifacts-account.json

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

hal config features edit --artifacts true
hal config artifact gcs enable


## This will edit the "gate" service
#  change the field type: ClusterIP to type: NodePort
KUBE_EDITOR="nano" kubectl edit svc spin-gate -n spinnaker --context $STAGING_CONTEXT

#Next, get the port that spin-gate has bound to. You can check this with
kubectl get svc spin-gate -n spinnaker --context $STAGING_CONTEXT
NODE_PORT=30521

#And get the external IP from any of the kube cluster nodes (using the browser UI https://console.cloud.google.com/compute/instances)
NODE_IP=35.196.159.74

# Now go to github and add this webhook from the settings page of the project,
# select type=json
ENDPOINT_GIT=http://$NODE_IP:$NODE_PORT/webhooks/git/github
ENDPOINT_DOCKERHUB=http://$NODE_IP:$NODE_PORT/webhooks/git/github







