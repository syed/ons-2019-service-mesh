export KUBECONFIG=`readlink -f kube_config_cluster.yml`
CLUSTER_NAME=$(basename $PWD)
export PS1="[$CLUSTER_NAME]$PS1"
