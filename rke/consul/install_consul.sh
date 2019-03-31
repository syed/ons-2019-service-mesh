#!/bin/bash
set -x
# kubectl apply -f local_storage_pv.yaml

# git clone https://github.com/hashicorp/consul-helm.git

# helm install --name consul ./consul-helm/ --values consul_helm_values.yaml

helm install --name nfs-provisioner --set nfs.server=10.221.29.245 \
	--set nfs.path=/var/nfsshare \
	--set storageClass.name=nfs \
	stable/nfs-client-provisioner
