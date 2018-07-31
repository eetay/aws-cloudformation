#!/bin/bash
if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; fi
ACTION=$1
MYDIR=`dirname $0`
STACK=RabbitClusterStack

case $ACTION in
  update|create)
    aws cloudformation ${ACTION}-stack --stack-name $STACK --template-body file:///Users/eetay/dev/aws/rabbit/rabbitcluster.cloudformation.yml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters ParameterKey=RabbitClusterVPC,ParameterValue=$AWS_DEFAULT_VPC
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  delete)
    aws cloudformation delete-stack --stack-name $STACK
    ;;
  *)
    echo "Usage: $0 [create|delete|update]"
    ;;
esac
