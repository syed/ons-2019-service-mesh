#!/bin/bash

terraform destroy -target module.istio_cluster  -target module.linkerd_cluster -target module.consul_cluster
