# ONS 2019

This automation spins up 3 kubernetes clusters each with
their own service mesh solution installed. First part of the
automation sets up the VMs in cloud.ca using Terraform and
generates the RKE config files.

The second half uses RKE to setup a kubernetes cluster on the
VMs. We use the `canal` CNI plugin.

## Setup

1. **Pre-Requeisites**: Install the following depdendencies and make sure that the binaries for each
of them are in `$PATH`

* kubectl
* terraform
* RKE
* gomplate
* helm

2. Clone the repo

```bash
git clone https://github.com/syed/ons-2019-service-mesh.git
cd ons-2019-service-mesh
```

3. Run `terraform apply`. It needs an API key from cloud.ca, you can pass in
as an env variable of via command line param to `terraform apply` or from `terraform.tfvars`
refer to terraform documentation

```bash
cd terraform
terraform apply
```

4. Setup VPN user in the VPC that is created in cloud.ca. Refer to the instructions in cloud.ca documentation

5. In the `rke` folder, for each of the service mesh cluster `istio`, `linkerd`, `consul` Setup the
kubernetes cluster using `rke up` 

```bash
cd <repo>
cd rke/{istio|linkerd|consul}
rke up
```

6. Once the cluster is up, install Helm and the service mesh

```
cd <repo>
cd rke/{istio|linkerd|consul}
source env.sh 			# Sets up kubeconfig
./init_cluster.sh 		# Installs helm on the cluster
./install_<servicemesh>.sh	# Installs the given servive mesh
```
