#!/bin/bash
if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; fi
ACTION=$1
MYDIR=`dirname $0`
STACK=RabbitClusterStack
S3TEMPLATES=s3://samanage-sandbox-cim-artifacts/$STACK

case $ACTION in
  update|create)
    cp vpc.cloudformation.yml ./s3bucket && aws s3 sync ./s3bucket $S3TEMPLATES
    aws cloudformation ${ACTION}-stack --stack-name $STACK \
      --template-body file://./rabbitcluster.cloudformation.yml \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
      --parameters \
        ParameterKey=InstanceKeyPair,ParameterValue=RabbitMQKeyPair \
        ParameterKey=S3Templates,ParameterValue=$S3TEMPLATES
        # ParameterKey=RabbitClusterVPC,ParameterValue=$AWS_DEFAULT_VPC \
        # ParameterKey=RabbitClusterVPCSubnets,ParameterValue=\"$AWS_DEFAULT_VPC_SUBNETS\" \
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  delete)
    aws cloudformation delete-stack --stack-name $STACK
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  *)
    echo "Usage: $0 [create|delete|update]"
    ;;
esac
