#!/usr/bin/env bash

kubectl create -f ./namespace-dev.json
kubectl create -f ./namespace-stage.json

#kubectl get namespaces
kubectl config view

hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_DEPLOY} \
    --provider-version v2 \
    --context ${KUBE_DEPLOY_CONTEXT}
hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_DEPLOY} \
    --provider-version v2 \
    --context ${KUBE_DEPLOY_CONTEXT}

kubectl config set-context dev --namespace=dev \
  --cluster=gke_np-beta_us-central1-c_np-deploy \
  --user=gke_np-beta_us-central1-c_np-deploy

kubectl config set-context stage --namespace=stage \
  --cluster=gke_np-beta_us-central1-c_np-deploy \
  --user=gke_np-beta_us-central1-c_np-deploy

hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_DEV} \
    --provider-version v2 \
    --context dev

hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_STAGE} \
    --provider-version v2 \
    --context stage

