#!/bin/bash
if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; fi
ACTION=$1
MYDIR=`dirname $0`
source config
STACKLOWERCASE=`echo "$STACK" | tr '[:upper:]' '[:lower:]'`
S3TEMPLATES=s3://$S3TEMPLATESBUCKET/$STACK
S3DATABUCKET=$STACKLOWERCASE-data-bucket
ELASTICDOMAIN=$STACKLOWERCASE-index

case $ACTION in
  update|create)
    cp *.cloudformation.yml ./s3bucket && aws s3 sync ./s3bucket $S3TEMPLATES
    aws cloudformation ${ACTION}-stack --stack-name $STACK \
      --template-body file://./s3lambdaelasticsearch.cloudformation.yml \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
      --parameters \
        ParameterKey=Project,ParameterValue=$STACK \
        ParameterKey=InstanceKeyPair,ParameterValue=OhioRegionKeypair \
        ParameterKey=ElasticDomainName,ParameterValue=$ELASTICDOMAIN \
        ParameterKey=S3TemplatesBucket,ParameterValue=$S3TEMPLATESBUCKET \
        ParameterKey=S3DataBucketName,ParameterValue=$S3DATABUCKET
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  delete)
    aws cloudformation delete-stack --stack-name $STACK
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  deploy)
    mkdir -p dist
    FUNC=$2
    if [ -z "$FUNC" ]; then
        echo "Usage: $0 deploy <Function Name>"
	exit 1
    fi
    pushd $FUNC > /dev/null || exit 1
    npm i
    zip -r ../dist/$FUNC.zip .
    popd > /dev/null
    aws lambda update-function-code --function-name $FUNC --zip-file fileb://./dist/$FUNC.zip
    ;;
  *)
    echo "Usage: $0 [create|delete|update]"
    echo "Usage: $0 deploy <Function Name>"
    echo "STACK=$STACK"
    ;;
esac
