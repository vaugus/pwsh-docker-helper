#!/bin/sh

main() {
  apk update && apk add openssh

  # deny password authentication and initialize hostkeys
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
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
