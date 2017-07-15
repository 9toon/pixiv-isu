#!/bin/bash

set -e

IPADDR=$1
KEY=$2

ssh -t -t -i ~/.ssh/$KEY isucon@$IPADDR sh <<SHELL
  echo ===== Deploying... =====

  cd /home/isucon/private_isu/webapp

  echo ===== Move... =====

  CURRENT_COMMIT=`git rev-parse HEAD`

  git pull --rebase origin master

  echo ===== Rotate log files =====
  if sudo test -f "/var/lib/mysql/mysqld-slow.log"; then
    echo == Roatate mysqld-slow.log ==
    sudo mv /var/lib/mysql/mysqld-slow.log /var/lib/mysql/mysqld-slow.log.$(date "+%Y%m%d_%H%M%S").$CURRENT_COMMIT
  fi

  if sudo test -f "/var/log/nginx/access.log"; then
    echo == Roatate access.log ==
    sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.$(date "+%Y%m%d_%H%M%S").$CURRENT_COMMIT
  fi

  echo ===== Copy sysctl.conf  =====
  if [ -f /etc/sysctl.conf ]; then
    sudo rm /etc/sysctl.conf
  fi

  sudo cp config/sysctl.conf /etc/sysctl.conf
  sudo chmod 0644 /etc/sysctl.conf

  sudo sysctl -p

  echo ===== Copy my.cnf  =====
  if [ -f /etc/my.cnf ]; then
    sudo rm /etc/my.cnf
  fi

  sudo cp config/my.cnf /etc/my.cnf
  sudo chmod 0400 /etc/my.cnf

  echo ===== Restart MySQL =====
  sudo service mysqld restart

  echo ===== Copy nginx.conf  =====
    if [ -f /etc/nginx/nginx.conf ]; then
    sudo rm /etc/nginx/nginx.conf
  fi

  sudo cp config/nginx.conf /etc/nginx/nginx.conf

  cd ruby

  echo ===== Bundle Install =====
  /home/isucon/.local/ruby/bin/bundle install

  echo ===== Restart nginx =====
  sudo /etc/init.d/nginx restart

  echo ===== Restart unicorn =====
  sudo systemctl restart isu-ruby

  echo ===== FINISHED =====

  exit
  exit
SHELL
