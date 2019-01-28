# rabbit-cluster

CloudFormation based installation of [RabbitMQ](https://www.rabbitmq.com/) cluster
includes scalability group, load balancer and RabbitMQ cluster configuration

For now, the CloudFormation uses custom AMI I've created specially for this project
based on AWS linux free AMI, on which RabbitMQ 3.7.7 was installed (see below)

This AMI is not included in the repo here, you have to build it and replace the AMI
ID in the cloudformation template

## Architecture

![alt text](./images/architecture.png)

Note: moving the RabbitMQ instances to the private subnets (right now they are
on the public subnets) is on my TODO list...

## Installation & deploy

#### Installation
- [create a KeyPair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) in AWS
- edit ```rabbitcluster.cloudformation.yaml``` and replace the KeyPair name with the newly created keypair.
- edit ```./aws-exec.sh``` and modify these two settings:

```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=my-aws-profile
```

#### First deploy
```bash
./rabbit-stack create
```

#### Deploying updated stack

whenever you update the CloudFormation template:

```bash
./rabbit-stack update
```

## Notes

The load balancer (ELB) is defined to be internal one, planning for production
configuration. If you wish, you can modify the CloudFormation template to be
internet-facing, in which case it's accessible to all

#### Accessing the internal ELB and the Rabbit cluster from your PC

If you choose to keep the production-oriented setup, your application might use
VPC peering to connect to the Rabbit cluster (via the ELB). However, you might need 
a way to connect to the ELB from your personal computer just for testing purposes
and administration:

Assuming you have a bastion host and wish to connect from anywhere in internet to the ELB
then you need to start these 2 tunnels - 1 for messaging (port 5672) of your application,
the other for administrative web UI (port 15672, connect from browser to http://localhost:8000
to view UI):

```bash
ssh -N -i ~/.ssh/MyKeyToMyBastionHost.pem -L 5672:internal-RabbitClusrLB-1649447701.us-east-1.elb.amazonaws.com:5672 ec2-user@my-bastion-host &
ssh -N -i ~/.ssh/MyKeyToMyBastionHost.pem -L 8000:internal-RabbitClusrLB-1649447701.us-east-1.elb.amazonaws.com:15672 ec2-user@my-bastion-host &
```

Then open a browser and access RabbitMQ's management UI using browser at 'http://localhost:8000'
The user/password are configured in the CloudFormation template
Have your test application connect to 'amqp://root:root@localhost:5672' to send and
recieve messages

#### Creating the RabbitMQ AMI

Installation is loosely based on "[Installing RabbitMQ With Erlang on AWS EC2 Amazon Linux Instance](https://dzone.com/articles/installing-rabbitmq-37-along-with-erlang-version-2)" 
with few fixes, without configuration (which is handled in the CloudFormation template, since we want that to
be updateable later on) and modified for RabbitMQ 3.7.7

Start off with the AWS free linux AMI and then install RabbitMQ like so:

```bash
cd /opt
sudo wget https://github.com/rabbitmq/erlang-rpm/releases/download/v20.1.7/erlang-20.1.7-1.el6.x86_64.rpm
sudo rpm -ivh erlang-20.1.7-1.el6.x86_64.rpm
sudo yum install socat
sudo wget https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.7/rabbitmq-server-3.7.7-1.el6.noarch.rpm
sudo rpm -ivh rabbitmq-server-3.7.7-1.el6.noarch.rpm
sudo service rabbitmq-server start
```

Take a snapshot of the machine, put the ID of your snapshot in the cloudformation template, and you're there!

#### TODO list:
* make use of private subnets for cluster instances
* use ec2 VPC endpoint instead of public IP addresses for cluster instances
* close the incoming TCP security on port 4369 discovery
* optimize for production guided by likes of [RabbitMQ Best Practice with CloudAMQP](https://www.slideshare.net/ErlangSolutionsLtd/rabbitmq-best-practice-with-cloudamqp)

