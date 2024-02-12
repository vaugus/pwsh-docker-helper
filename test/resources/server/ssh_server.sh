#!/bin/sh

apk update && apk add openssh

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
mkdir -p ~/.ssh

ssh-keygen -A 

mv ~/authorized_keys ~/.ssh 
chmod 700 /root/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R root:root ~/.ssh/authorized_keys

docker ps

/usr/sbin/sshd -D -e &