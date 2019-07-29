#!/bin/bash
if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; fi
ACTION=$1
MYDIR=`dirname $0`
STACK=DemoStack
S3TEMPLATESBUCKET=preconfigured-temlate-bucket
S3TEMPLATES=s3://$S3TEMPLATESBUCKET/$STACK

case $ACTION in
  update|create)
    cp *.cloudformation.yml ./s3bucket && aws s3 sync ./s3bucket $S3TEMPLATES
    aws cloudformation ${ACTION}-stack --stack-name $STACK \
      --template-body file://./s3lambdaelasticsearch.cloudformation.yml \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
      --parameters \
        ParameterKey=InstanceKeyPair,ParameterValue=OhioRegionKeypair \
        ParameterKey=S3TemplatesBucket,ParameterValue=$S3TEMPLATESBUCKET \
        ParameterKey=S3DataBucketName,ParameterValue=preconfigured-template-bucket
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  delete)
    aws cloudformation delete-stack --stack-name $STACK
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  deploy)
    mkdir -p dist
    FUNC=$2
    pushd $FUNC > /dev/null
    zip -r ../dist/$FUNC.zip .
    popd > /dev/null
    aws lambda update-function-code --function-name $FUNC --zip-file fileb://./dist/$FUNC.zip
    ;;
  *)
    echo "Usage: $0 [create|delete|update]"
    echo "Usage: $0 deploy <Function Name>"
    ;;
esac
