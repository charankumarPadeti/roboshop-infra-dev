#!/bin/bash
component=$1
environment=$2  #dont use env here , because it is reserved in linux
yum install python3.12-devel python3.12-pip -y
pip3.12 install ansible ansible-core==2.16 botocore boto3          #botocore boto3 anti ante ansible aws ni connect avvali ante we need to have aws python packages(botocore boto3)
ansible-pull -U https://github.com/charankumarPadeti/roboshop-ansible-roles-tf.git -e component=$component -e env=$environment main-tf.yaml