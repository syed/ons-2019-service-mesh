variable "environment_id" {
}

variable "prefix" {
}

variable "vpc_id" {
}

variable "template_name" {
}

variable "compute_offering" {
}

variable "node_ram" {
}

variable "node_vcpu" {
}

variable "node_disk_gb" {
}

variable "cloudinit" {
}

variable "node_count" {
}



resource "cloudca_network" "cluster_network" {
  environment_id   = "${var.environment_id}"
  name             = "${format("%s-network", var.prefix)}"
  description      = "Network for the nodes"
  vpc_id           = "${var.vpc_id}"
  network_offering = "Load Balanced Tier"
  network_acl   = "${cloudca_network_acl.nw_acl.id}"
}

resource "cloudca_network_acl" "nw_acl" {
  environment_id = "${var.environment_id}"
  name           = "${format("%s-acl", var.prefix)}"
  description    = "ACL for Kubernetes node"
  vpc_id         = "${var.vpc_id}"
}

resource "cloudca_network_acl_rule" "allow_ingress" {
  environment_id = "${var.environment_id}"
  rule_number    = 101
  action         = "Allow"
  protocol       = "TCP"
  start_port     = 1
  end_port       = 65535
  cidr           = "0.0.0.0/0"
  traffic_type   = "Ingress"
  network_acl_id = "${cloudca_network_acl.nw_acl.id}"
}


//Create nodes

resource "cloudca_instance" "node" {
  environment_id         = "${var.environment_id}"
  name                   = "${format("%s-node-%d", var.prefix, count.index + 1)}"
  network_id             = "${cloudca_network.cluster_network.id}"
  template               = "${var.template_name}"
  compute_offering       = "${var.compute_offering}"
  cpu_count              = "${var.node_vcpu}"
  memory_in_mb           = "${var.node_ram}"
  root_volume_size_in_gb = "${var.node_disk_gb}"
  user_data              = "${var.cloudinit}"
  count                  = "${var.node_count}"
}

output "node_ips" {
  value = ["${cloudca_instance.node.*.private_ip}"]
}

output "network_id" {
  value = "${cloudca_network.cluster_network.id}"
}

