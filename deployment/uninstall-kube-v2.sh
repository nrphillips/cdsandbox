#!/usr/bin/env bash

SPIN_INSTALL_SOURCE=~/projects/cdsandbox/deployment

source ${SPIN_INSTALL_SOURCE}/settings.sh

# ################################################################
# Uninstall spinnaker

hal deploy clean -q

# First get gcloud's default settings aligned with the project
gcloud config set compute/region ${SPINNAKER_INSTALL_CLUSTER_REGION}
gcloud config set compute/zone ${SPINNAKER_INSTALL_CLUSTER_ZONE}
gcloud config set core/project ${SPINNAKER_INSTALL_PROJECT_NAME}

# TODO: Need to add something here that deletes the docker images
# from GCR.For now do this manually.
#read -p "TODO: Need to add something here that deletes the docker images rom GCR.For now do this manually"

gcloud projects remove-iam-policy-binding -q ${SPINNAKER_INSTALL_PROJECT_NAME} --role roles/browser \
    --member serviceAccount:${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}
gcloud projects remove-iam-policy-binding -q ${SPINNAKER_INSTALL_PROJECT_NAME} --role roles/storage.admin \
    --member serviceAccount:${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}
gcloud projects remove-iam-policy-binding -q ${SPINNAKER_INSTALL_PROJECT_NAME} --role roles/storage.admin \
    --member serviceAccount:${SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL}

gcloud iam service-accounts delete -q ${SPINNAKER_GCS_SERVICE_ACCOUNT_EMAIL}
gcloud iam service-accounts delete -q ${SPINNAKER_GCR_SERVICE_ACCOUNT_EMAIL}

hal config provider docker-registry account delete ${DOCKER_REGISTRY_ACCOUNT}
hal config provider docker-registry disable

hal config provider kubernetes account delete ${KUBE_ACCOUNT_V2_INSTALL}
hal config provider kubernetes account delete ${KUBE_ACCOUNT_V2_DEPLOY}
hal config provider kubernetes account delete ${KUBE_ACCOUNT_V2_DEV}
hal config provider kubernetes account delete ${KUBE_ACCOUNT_V2_STAGE}
hal config provider kubernetes disable

hal config artifact bitbucket account delete ${BITBUCKET_ACCOUNT_NAME}
hal config artifact bitbucket disable
hal config features edit --artifacts false

kubectl delete serviceaccount spinnaker-service-account --namespace spinnaker --context ${KUBE_INSTALL_CONTEXT}
kubectl delete serviceaccount spinnaker-service-account --namespace spinnaker --context ${KUBE_DEPLOY_CONTEXT}

kubectl config unset current-context
kubectl config delete-context ${KUBE_INSTALL_CONTEXT}
kubectl config delete-context ${KUBE_DEPLOY_CONTEXT}
kubectl config unset users.gke_np-beta_us-east1-b_np-deploy-token-user

# Remove the storage bucket that spinnaker uses to maintain it's state.
gsutil rm -r gs://${SPINNAKER_INSTALL_GCSBUCKET_NAME}/

gcloud container clusters delete -q ${SPINNAKER_DEPLOY_CLUSTER_FULLNAME}
gcloud container clusters delete -q ${SPINNAKER_INSTALL_CLUSTER_FULLNAME}

