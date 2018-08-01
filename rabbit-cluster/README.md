# rabbit-cluster

CloudFormation based installation of [RabbitMQ](https://www.rabbitmq.com/) cluster
includes scalability group, load balancer and RabbitMQ cluster configuration

For now, the CloudFormation uses AMI based on AWS linux free AMI, on which RabbitMQ 3.7.7 was
preinstalled. This AMI is not included in the repo here, you have to build it
and replace the AMI ID in the cloudformation template

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