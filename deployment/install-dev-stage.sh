#!/usr/bin/env bash

kubectl create -f ./namespace-dev.json
kubectl create -f ./namespace-stage.json

kubectl config view

hal config provider kubernetes account add ${KUBE_ACCOUNT_V2_DEPLOY} \
    --provider-version v2 \
    --context ${KUBE_DEPLOY_CONTEXT}

kubectl config set-context dev --namespace=dev \
  --cluster=gke_np-beta_us-east1-b_np-deploy \
  --user=gke_np-beta_us-east1-b_np-deploy-token-user

kubectl config set-context stage --namespace=stage \
  --cluster=gke_np-beta_us-east1-b_np-deploy \
  --user=gke_np-beta_us-east1-b_np-deploy-token-user
