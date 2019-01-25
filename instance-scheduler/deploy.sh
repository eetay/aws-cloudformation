#!/bin/bash
#if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; fi
ACTION=$1
MYDIR=`dirname $0`
STACK=Ec2SchedulerStack
mkdir -p $MYDIR/dist

case $ACTION in
  update|create)
    aws cloudformation ${ACTION}-stack --stack-name $STACK \
      --template-body file://./cloudformation.yaml \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  deploy)
    ZIP=SchedulerLambda.zip
    pushd SchedulerLambda > /dev/null && zip ../dist/$ZIP -r . && popd > /dev/null
    aws lambda update-function-code --function-name $STACK-SchedulerLambda --zip-file fileb://./dist/$ZIP
    ;;
  delete)
    aws cloudformation delete-stack --stack-name $STACK
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  *)
    echo "Usage: $0 [create|delete|update|deploy]"
    ;;
esac
