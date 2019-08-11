#!/bin/bash
if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; echo; fi
ACTION=$1
MYDIR=`dirname $0`
source config
STACKLOWERCASE=`echo "$STACK" | tr '[:upper:]' '[:lower:]'`
S3TEMPLATES=s3://$S3TEMPLATESBUCKET/$STACK
S3DATABUCKET=$STACKLOWERCASE-backup-bucket

case $ACTION in
  update|create|stage)
    if [ $ACTION == stage ]; then
      if [ "$2" == "--force" ]; then
        aws cloudformation delete-change-set --stack-name $STACK --change-set-name changeset-stage
      else
        echo "(!) There is already a staged change."
        echo "'$0 show-stage' to review"
        exit 1
      fi
      CF_ACTION=create-change-set
      CHANGESET="--change-set-name changeset-stage"
    else
      CF_ACTION=${ACTION}-stack
    fi
    cp *.cloudformation.yml ./s3bucket && aws s3 sync ./s3bucket $S3TEMPLATES
    aws cloudformation ${CF_ACTION} --stack-name $STACK \
      --template-body file://./personifi.cloudformation.yml \
      --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
      --parameters \
        ParameterKey=Project,ParameterValue=$PROJECT \
        ParameterKey=InstanceKeyPair,ParameterValue=OhioRegionKeypair \
        ParameterKey=S3TemplatesBucket,ParameterValue=$S3TEMPLATESBUCKET \
        ParameterKey=S3BackupBucketName,ParameterValue=$S3DATABUCKET \
        $CHANGESET
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    if [ $ACTION == change-set ]; then
        sleep 3
        aws cloudformation describe-change-set --stack-name $STACK --change-set-name changeset-stage | jq '.Changes[]'
    fi
    ;;
  commit)
    aws cloudformation execute-change-set --stack-name $STACK --change-set-name changeset-stage
    ./cloudformation-tail.sh $STACK $AWS_REGION $AWS_PROFILE
    ;;
  show|show-staged?)
    aws cloudformation describe-change-set --stack-name $STACK --change-set-name changeset-stage | jq '.Changes[]'
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
    aws lambda update-function-code --function-name $STACK-$FUNC --zip-file fileb://./dist/$FUNC.zip
    ;;
  *)
    echo "Usage: $0 <command>"
    echo "commands:"
    echo "    create - create $STACK"
    echo "    delete - delete $STACK"
    echo "    update - update existing $STACK"
    echo "    deploy <Function-Name> - update lambda code"
    echo "staging commands:"
    echo "    stage [--force] - stage an update for $STACK"
    echo "    show-staged - show the staged update for $STACK"
    echo "    commit - update $STACK by executing staged update"
    ;;
esac
