{{ $roles := slice "etcd" "controlplane" "worker" }}
---
nodes:
{{ range  $index, $ip  := (ds "data") }}
  - address: {{ $ip }}
    user: kubernetes
    ssh_key_path: id_rsa
    role: [{{ index $roles $index }}]
{{ end }}
services:
  etcd:
    image: quay.io/coreos/etcd:latest
  kube-api:
    image: rancher/k8s:v1.12.7-rancher1-1
  kube-controller:
    image: rancher/k8s:v1.12.7-rancher1-1
  scheduler:
    image: rancher/k8s:v1.12.7-rancher1-1
  kubelet:
    image: rancher/k8s:v1.12.7-rancher1-1
  kubeproxy:
    image: rancher/k8s:v1.12.7-rancher1-1
