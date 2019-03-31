#cloud-config

package_upgrade: true

packages:
  - vim
  - bash-completion
  - nfs-utils

users:
  - name: cca-user
    lock_passwd: true
  - name: ${username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - "${public_key}"

runcmd:
  - systemctl stop firewalld
  - systemctl disable firewalld
  - setenforce 0
  - "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config"
  - mkdir /var/nfsshare
  - chmod -R 755 /var/nfsshare
  - chown nfsnobody:nfsnobody /var/nfsshare
  - systemctl daemon-reload
  - echo "/var/nfsshare    *(rw,sync,no_root_squash,no_all_squash)" > /etc/exports
  - systemctl enable rpcbind
  - systemctl enable nfs-server
  - systemctl enable nfs-lock
  - systemctl enable nfs-idmap
  - systemctl start rpcbind
  - systemctl start nfs-server
  - systemctl start nfs-lock
  - systemctl start nfs-idmap
