# rabbit-cluster

CloudFormation based installation of [RabbitMQ](https://www.rabbitmq.com/) cluster
includes scalability group, load balancer and RabbitMQ cluster configuration

For now, the CloudFormation uses custom AMI I've created specially for this project
based on AWS linux free AMI, on which RabbitMQ 3.7.7 was installed (see below)

This AMI is not included in the repo here, you have to build it and replace the AMI
ID in the cloudformation template


# Installation/Deploy

## 1st deploy
```bash
./rabbit-stack create
```

## After 1st deploy
whenever you update the CloudFormation template:
```bash
./rabbit-stack update
```

# Creating RabbitMQ AMI

Start with AWS linux free AMI and install RabbitMQ like so:

```bash
cd /opt
sudo wget https://github.com/rabbitmq/erlang-rpm/releases/download/v20.1.7/erlang-20.1.7-1.el6.x86_64.rpm
sudo rpm -ivh erlang-20.1.7-1.el6.x86_64.rpm
sudo yum install socat
sudo wget https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.7/rabbitmq-server-3.7.7-1.el6.noarch.rpm
sudo rpm -ivh rabbitmq-server-3.7.7-1.el6.noarch.rpm
sudo service rabbitmq-server start
```

Installation is loosely based on "[Installing RabbitMQ With Erlang on AWS EC2 Amazon Linux Instance](https://dzone.com/articles/installing-rabbitmq-37-along-with-erlang-version-2)"
