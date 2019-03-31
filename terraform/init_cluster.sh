export KUBECONFIG=$1

kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller \
	  --clusterrole=cluster-admin \
	    --serviceaccount=kube-system:tiller

helm init --service-account tiller --wait

# Test
kubectl -n kube-system  rollout status deploy/tiller-deploy
helm version
