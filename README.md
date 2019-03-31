# ONS 2019

This automation spins up 3 kubernetes clusters each with
their own service mesh solution installed. First part of the
automation sets up the VMs in cloud.ca using Terraform and
generates the RKE config files.

The second half uses RKE to setup a kubernetes cluster on the
VMs. We use the `canal` CNI plugin.
