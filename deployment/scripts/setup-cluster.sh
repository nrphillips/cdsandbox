#!/usr/bin/env bash
## ######################################################################################
## Inital kubernetes cluster setup
## ######################################################################################

#source settings.sh

# First get gcloud's default settings aligned with the project
gcloud config set compute/region ${SPINNAKER_INSTALL_CLUSTER_REGION}
gcloud config set compute/zone ${SPINNAKER_INSTALL_CLUSTER_ZONE}
gcloud config set container/use_client_certificate true
gcloud config set core/project ${SPINNAKER_INSTALL_PROJECT_NAME}

# Review these config values for stale configurations, they may as well be removed
# if they're not in use. You can remove them via "kubectl config delete-cluster" and
# kubectl config delete-context"

kubectl config get-clusters
kubectl config get-contexts
#read -p "Review the above output there should be no configured contexts or clusters..."

## Set up the GKE cluster that will host Spinnaker
#  Note: use_client_certificate and --enable-legacy-authorization are necessary unless we're using RBAC
#  (Role-based access control), which we can certainly do at some point.
#
gcloud config set container/use_client_certificate true


# The "Small" cluster version (and presumably cheaper) is
# --machine-type=g1-small,
# --cluster-version=1.11.5-gke.5
# --num-nodes=1

# When I didn't use at least --num-nodes=2 --machine-type=n1-standard-2 the gcp console indicated
# that I didn't have enough resources to run all of the spinnaker processes (igor, rosco, etc)

# If this is a new project, you need to go to the GCP dashboard and select the Kubernetes Engine
# menu, where it will go through the enablement process. I don't know what gcloud command to issue to
# do this automatically.
gcloud container clusters create ${SPINNAKER_INSTALL_CLUSTER_FULLNAME} \
    -q --num-nodes=2 --machine-type=n1-standard-2 --cluster-version=latest \
    --enable-legacy-authorization

gcloud container clusters get-credentials ${SPINNAKER_INSTALL_CLUSTER_FULLNAME} \
    -q --zone ${SPINNAKER_INSTALL_CLUSTER_ZONE} \
    --project ${SPINNAKER_INSTALL_PROJECT_NAME}

