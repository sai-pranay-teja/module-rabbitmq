#!/bin/bash

sudo ansible-pull -i localhost, -U https://github.com/sai-pranay-teja/roboshop-ansible.git roboshop-app.yml -e components=${component} >/opt/ansible.log
