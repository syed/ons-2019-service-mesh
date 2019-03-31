#!/bin/bash
set -x

export KUBECONFIG=`readlink -f kube_config_cluster.yaml`

# Download istio


cd istio-1.1.1
helm install install/kubernetes/helm/istio-init \
	--set gateways.istio-ingressgateway.type=NodePort \
	--name istio-init --namespace istio-system

kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l

helm install install/kubernetes/helm/istio \
       	--name istio --namespace istio-system \
	--values install/kubernetes/helm/istio/values-istio-demo-auth.yaml \
	--set gateways.istio-ingressgateway.type=NodePort

kubectl get svc -n istio-system
kubectl get pods -n istio-system

cd ..
# Uninstall
# helm delete --purge istio
# helm delete --purge istio-init
