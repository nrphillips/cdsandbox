#!/usr/bin/env bash

source settings.sh

kubectl config set-context ${KUBE_CONTEXT}
kubectl config set current-context ${KUBE_CONTEXT}

source ./scripts/setup-cluster.sh
source ./scripts/setup-kube.sh
source ./scripts/setup-gcr.sh

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

#hal config provider docker-registry account edit ${DOCKER_REGISTRY_ACCOUNT} --add-repository ${DOCKER_REPOSITORY}

# Enable the docker-registry provider
hal config provider docker-registry enable

# Add the kubernetes account that spinnaker will use to access kube.
KUBE_CONTEXT=$(kubectl config current-context)

hal config provider kubernetes account add ${KUBE_ACCOUNT_V1} \
    --docker-registries ${DOCKER_REGISTRY_ACCOUNT}

#    --provider-version v1 \

# Ensure kubernetes is enabled
hal config provider kubernetes enable

## Install Spinnaker on Kubernetes
hal config deploy edit --type distributed --account-name ${KUBE_ACCOUNT_V1}

# Need to bounce halyard by shutting down then issuing any hal command
hal shutdown

## ######################################################################################
## Now deploy spinnaker

# This might need to be done manually because you need to select a version
# that's available from this list.
# hal version list
hal config version edit --version $SPINNAKER_VERSION

hal deploy apply

