variable "api_key" {}

variable "service_code" {
  default = "compute-qc"
}

variable "organization_code" {
    default = "asf"
}

variable "admin" {
  type = "list"
  default = ["sahmed"]
}

variable "read_only" {
  type = "list"
  default = []
}

variable "zone_id" {
  default = "QC-2"
}

variable "prefix" {
  default = "ons"
}

variable "username" {
  default = "kubernetes"
}

variable "node_count" {
  default = 3
}

variable "template_name" {
  default = "CentOS 7.4 HVM"
}

variable "compute_offering" {
  default = "Standard"
}

variable "node_ram" {
  default = 4096
}

variable "node_vcpu" {
  default = 2
}

variable "node_disk_gb" {
  default = 20
}