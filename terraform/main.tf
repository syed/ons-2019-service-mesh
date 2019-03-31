provider "cloudca" {
  api_key = "${var.api_key}"
}

resource "cloudca_environment" "ons_cluster" {
  service_code      = "${var.service_code}"
  organization_code = "${var.organization_code}"
  name              = "${format("%s-env", var.prefix)}"
  description       = "Environment for a Kubernetes cluster"
  admin_role        = ["${var.admin}"]
  read_only_role    = ["${var.read_only}"]
}

resource "cloudca_vpc" "cluster_vpc" {
  environment_id = "${cloudca_environment.ons_cluster.id}"
  name           = "${format("%s-vpc", var.prefix)}"
  description    = "VPC for a Kubernetes cluster"
  vpc_offering   = "Default VPC offering"
  zone           = "${var.zone_id}"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_key_private" {
  content  = "${tls_private_key.ssh_key.private_key_pem}"
  filename = "./id_rsa"

  provisioner "local-exec" {
    command = "chmod 400 ./id_rsa"
  }
}

resource "local_file" "ssh_key_public" {
  content  = "${tls_private_key.ssh_key.public_key_openssh}"
  filename = "./id_rsa.pub"
}

data "template_file" "cloudinit_k8s" {
  template = "${file("templates/cloudinit_k8s.tpl")}"

  vars {
    public_key = "${replace(tls_private_key.ssh_key.public_key_openssh, "\n", "")}"
    username   = "${var.username}"
  }
}

data "template_file" "cloudinit_nfs" {
  template = "${file("templates/cloudinit_nfs.tpl")}"

  vars {
    public_key = "${replace(tls_private_key.ssh_key.public_key_openssh, "\n", "")}"
    username   = "${var.username}"
  }
}


// Creating different clusters

// Istio cluster
module "istio_cluster" {
  source = "./modules/kubernetes_cluster"

  prefix = "istio"
  environment_id = "${cloudca_environment.ons_cluster.id}"
  vpc_id = "${cloudca_vpc.cluster_vpc.id}"

  template_name = "${var.template_name}"
  compute_offering = "${var.compute_offering}"
  node_vcpu = "${var.node_vcpu}"
  node_ram = "${var.node_ram}"
  node_disk_gb = "${var.node_disk_gb}"
  cloudinit = "${data.template_file.cloudinit_k8s.rendered}"

  node_count = "${var.node_count}"

}

output "istio_nodes" {
  value = "${module.istio_cluster.node_ips}"
}

resource "null_resource" "istio_rke_config" {
  triggers {
        run_always = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "echo ${jsonencode(module.istio_cluster.node_ips)} | ./gen_rke_config.sh istio"
  }
}


// Linkerd cluster
module "linkerd_cluster" {
  source = "./modules/kubernetes_cluster"

  prefix = "linkerd"
  environment_id = "${cloudca_environment.ons_cluster.id}"
  vpc_id = "${cloudca_vpc.cluster_vpc.id}"

  template_name = "${var.template_name}"
  compute_offering = "${var.compute_offering}"
  node_vcpu = "${var.node_vcpu}"
  node_ram = "${var.node_ram}"
  node_disk_gb = "${var.node_disk_gb}"
  cloudinit = "${data.template_file.cloudinit_k8s.rendered}"

  node_count = "${var.node_count}"

}

output "linkerd_nodes" {
  value = "${module.linkerd_cluster.node_ips}"
}

resource "null_resource" "linkerd_rke_config" {
  triggers {
        run_always = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "echo ${jsonencode(module.linkerd_cluster.node_ips)} | ./gen_rke_config.sh linkerd"
  }
}



// Consul cluster
module "consul_cluster" {
  source = "./modules/kubernetes_cluster"

  prefix = "consul"
  environment_id = "${cloudca_environment.ons_cluster.id}"
  vpc_id = "${cloudca_vpc.cluster_vpc.id}"

  template_name = "${var.template_name}"
  compute_offering = "${var.compute_offering}"
  node_vcpu = "${var.node_vcpu}"
  node_ram = "${var.node_ram}"
  node_disk_gb = "${var.node_disk_gb}"
  cloudinit = "${data.template_file.cloudinit_k8s.rendered}"

  node_count = "${var.node_count}"

}

output "consul_nodes" {
  value = "${module.consul_cluster.node_ips}"
}

resource "null_resource" "consul_rke_config" {
  triggers {
        run_always = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "echo ${jsonencode(module.consul_cluster.node_ips)} | ./gen_rke_config.sh consul"
  }
}

// NFS server for consul
resource "cloudca_instance" "nfs_server" {
  environment_id 	 = "${cloudca_environment.ons_cluster.id}"
  name                   = "${format("%s-node-%d", var.prefix, count.index + 1)}"
  network_id 		 = "${module.consul_cluster.network_id}"
  template               = "${var.template_name}"
  compute_offering       = "${var.compute_offering}"
  cpu_count              = "${var.node_vcpu}"
  memory_in_mb           = "${var.node_ram}"
  root_volume_size_in_gb = "${var.node_disk_gb}"
  user_data 		 = "${data.template_file.cloudinit_nfs.rendered}"
}

output "nfs_server_ip" {
  value = "${cloudca_instance.nfs_server.private_ip}"
}

