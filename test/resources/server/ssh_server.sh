#!/bin/sh

set +x

main() {
  apk update && apk add openssh

  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
  sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
  mkdir -p ~/.ssh
  ssh-keygen -A 

  # setup the docker_helper.pub key as an authorized key
  mv ~/authorized_keys ~/.ssh 
  chmod 700 /root/.ssh
  chmod 600 ~/.ssh/authorized_keys
  chown -R root:root ~/.ssh/authorized_keys

  # sanity check
  docker ps

  # start the ssh server
  /usr/sbin/sshd -D -e &
}

main "$@"
