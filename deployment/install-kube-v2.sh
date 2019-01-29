#!/usr/bin/env bash

## You'll need to set this variable to the location of the directory containing this script.
## Don't know how to import it from the environment yet.
SPIN_INSTALL_SOURCE=~/projects/cdsandbox/deployment

source ${SPIN_INSTALL_SOURCE}/settings.sh
source ${SPIN_INSTALL_SOURCE}/scripts/setup-clusterv2.sh
source ${SPIN_INSTALL_SOURCE}/scripts/setup-kubev2.sh
source ${SPIN_INSTALL_SOURCE}/scripts/setup-gcr.sh

# Enable the docker-registry provider
hal config provider docker-registry enable

# Add the registry provider to spinnaker
hal config provider docker-registry account add ${DOCKER_REGISTRY_ACCOUNT} \
--address ${DOCKER_REGISTRY_ADDRESS} \
--username _json_key \
--password-file ${SPINNAKER_GCR_SERVICE_ACCOUNT_DEST}

#--repositories [${DOCKER_REPOSITORY}] \

# And update the registry with my docker repository
# note that it has to contain both the project and repository name. Theoretically spinnaker can
# pick this up without having to add the repository explicitly, but I found that to not be the case so
# I had to add it by hand.

# Can't do this with multi-level repositories. instead need to enable the Resource Manager API in the gcloud.
# hal config provider docker-registry account edit ${DOCKER_REGISTRY_ACCOUNT} --add-repository ${DOCKER_REPOSITORY}

# Ensure kubernetes is enabled
hal config provider kubernetes enable

# Add the kubernetes account that spinnaker will use to access the installation kubernetes cluster.
#KUBE_CONTEXT=$(kubectl config current-context)
hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_INSTALL} \
    --provider-version v2 \
    --context ${KUBE_INSTALL_CONTEXT} \
    --docker-registries ${DOCKER_REGISTRY_ACCOUNT}

# Add the kubernetes account that spinnaker will use for deployment
hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_DEPLOY} \
    --provider-version v2 \
    --context ${KUBE_DEPLOY_CONTEXT}
#    --docker-registries ${DOCKER_REGISTRY_ACCOUNT}

hal config features edit --artifacts true

## Install Spinnaker on Kubernetes
hal config deploy edit --type distributed --account-name ${KUBE_ACCOUNT_V2_INSTALL}

## Install Spinnaker on Kubernetes
#hal config deploy edit --type distributed --account-name ${KUBE_ACCOUNT_V2_INSTALL}
#hal config provider kubernetes account delete ${KUBE_ACCOUNT_V1_INSTALL}
#hal config provider kubernetes account delete ${KUBE_ACCOUNT_V1_DEPLOY}
#hal config provider kubernetes account edit ${KUBE_ACCOUNT_V1_INSTALL}
#hal config provider kubernetes account edit ${KUBE_ACCOUNT_V1_DEPLOY}

# Need to bounce halyard by shutting down then issuing any hal command
hal shutdown

## ######################################################################################
## Now deploy spinnaker

# This might need to be done manually because you need to select a version
# that's available from this list.
# hal version list
hal config version edit --version $SPINNAKER_VERSION

hal deploy apply

# Create a pipeline.
# Step 0: The Cofiguration setting trigger should reference Docker Registry, you should be able to select the
# docker repository from the dropdowns if it was configured correctly.
# Set up Expected Artifacts
# Match Against "Docker"
# Docker image should be gcr.io/np-beta/demoservice
#
# Step 1: Create a Deploy(Manifest) step
# Account should be the Deploy cluster, not the install cluster.
# Manifest Source, when I did it I used text, and I copied in the contesnts of test-cluster-pipeline.yaml
# Req. Artifacts To Bind: I was able to select the docker image in the dropdown.

