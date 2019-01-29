#!/usr/bin/env bash

##
## Create a Kubernetes Service Account
##
## https://www.spinnaker.io/setup/install/providers/kubernetes-v2/#optional-create-a-kubernetes-service-account
##
## point kube to the install context.
## kubectl config get-contexts
kubectl config set current-context ${KUBE_INSTALL_CONTEXT}

# This service account uses the ClusterAdmin role -- this is not necessary,
# more restrictive roles can by applied.
kubectl apply --context ${KUBE_INSTALL_CONTEXT} \
    -f https://spinnaker.io/downloads/kubernetes/service-account.yml

INSTALL_TOKEN=$(kubectl get secret --context ${KUBE_INSTALL_CONTEXT} \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context ${KUBE_INSTALL_CONTEXT} \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)

kubectl config set-credentials ${KUBE_INSTALL_CONTEXT}-token-user --token $INSTALL_TOKEN

kubectl config set-context ${KUBE_INSTALL_CONTEXT} --user ${KUBE_INSTALL_CONTEXT}-token-user

# I'm going to create an identical service account in the deploy context, the account is dictated by the
# service-account.yml and I'm not certain if I'm allowed to change it?
kubectl apply --context ${KUBE_DEPLOY_CONTEXT} \
    -f https://spinnaker.io/downloads/kubernetes/service-account.yml

# Now do the same thing to the deploy cluster.
DEPLOY_TOKEN=$(kubectl get secret --context ${KUBE_DEPLOY_CONTEXT} \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context ${KUBE_DEPLOY_CONTEXT} \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)

kubectl config set-credentials ${KUBE_DEPLOY_CONTEXT}-token-user --token $DEPLOY_TOKEN

kubectl config set-context ${KUBE_DEPLOY_CONTEXT} --user ${KUBE_DEPLOY_CONTEXT}-token-user

## ######################################################################################################
## Grant Spinnaker permissions to GCS (Google Cloud Storage)
## Spinnaker requires an external storage provider for persisting application settings and
## configured pipelines. Because these data are sensitive and can be costly to lose, we recommend
## you use a hosted storage solution you are confident in.

# Create a bucket to hold spinnaker assets
gsutil mb gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}/

# Create a bucket to hold deployment manifests
#gsutil mb gs://${SPINNAKER_DEPLOY_MANIFESTSBUCKET_NAME}/

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
# Not sure if I need this gsutil iam ch serviceAccount:${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}:roles/storage.admin gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}

# grant permissions on the bucket to the service account
#gsutil iam ch serviceAccount:${SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL}:roles/storage.admin gs://${SPINNAKER_DEPLOY_MANIFESTSBUCKET_NAME}

# Tell spinnaker that we're using the specified gcs bucket.
hal config storage gcs edit --project ${SPINNAKER_INSTALL_PROJECT_NAME} \
    --bucket ${SPINNAKER_INSTALL_GCSBUCKET_NAME} \
    --bucket-location ${SPINNAKER_INSTALL_GCSBUCKET_LOCATION} \
    --json-path ${SPINNAKER_GCS_SERVICE_ACCOUNT_DEST}

hal config storage edit --type gcs
