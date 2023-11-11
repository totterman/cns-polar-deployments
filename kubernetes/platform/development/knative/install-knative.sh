#!/usr/bin/env sh

set -euo pipefail
echo "-> Installing Knative CRDs..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.3/serving-crds.yaml

echo "-> Installing Knative Serving..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.3/serving-core.yaml

echo "-> Installing Kourier Ingress..."
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.8.1/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

echo "-> Configuring DNS..."

kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"127.0.0.1.sslip.io":""}}'

kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.3/serving-default-domain.yaml

echo "-> Knative succesfully installed!"