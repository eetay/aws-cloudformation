#!/bin/bash
MYDIR=`dirname $0`
export AWS_EXEC=1
export AWS_SDK_LOAD_CONFIG=1
export AWS_DEFAULT_REGION=us-east-2
export AWS_PROFILE=Eetay.Natan@harman.com
export AWS_DEFAULT_VPC=`aws ec2 describe-vpcs --filters='{"Name":"isDefault","Values":["true"]}' --output text --query 'Vpcs[0].VpcId'`
export AWS_DEFAULT_VPC_SUBNETS=`aws ec2 describe-subnets --filters='{"Name":"vpc-id","Values":["'$AWS_DEFAULT_VPC'"]}' --output text --query 'Subnets[*].SubnetId' |  sed 's/\t/,/g'`
export HOST_IP=`ifconfig | grep 192.168.1 | head -1 | sed 's/ net.*$//;s/^.* 192/192/'`
if [ "$1" == "--silent" ]; then
	shift
else
	export | grep AWS | sed 's/^.*AWS/AWS/g'
fi
"$@"
