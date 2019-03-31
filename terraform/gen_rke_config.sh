#!/bin/bash
#!/bin/bash
set -x
CLUSTER_NAME=$1
RKE_DIR=../rke/${CLUSTER_NAME}
mkdir -p ${RKE_DIR}

# echo $NODE_IPS | gomplate -f templates/rke_config.tpl -d data=stdin:?type=application/array%2Bjson > ../rke/$CLUSTER_NAME/cluster.yml
read NODE_IPS
echo $NODE_IPS | gomplate -f templates/rke_config.tpl -d data=stdin:?type=application/array%2Bjson > ${RKE_DIR}/cluster.yml

cp id_rsa $RKE_DIR
cp id_rsa.pub $RKE_DIR
cp init_cluster.sh $RKE_DIR
cp env.sh ${RKE_DIR}
