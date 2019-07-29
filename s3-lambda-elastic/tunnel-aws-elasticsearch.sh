#!/bin/bash
SSH="ssh -nNT -i ~/.ssh/OhioRegionKeypair.pem"
BASTION=ec2-user@ec2-52-14-190-167.us-east-2.compute.amazonaws.com
source config
ES_HOST=$(./aws-exec.sh aws cloudformation list-exports --output text --query 'Exports[?Name==`'${STACK}'ElasticsearchEndpoint`].Value' | tail -1)
function terminate() {
	echo "Terminating SSHs: $(jobs -p)"
	kill $(jobs -p)
}
if [ "$1" == "--kill" ]; then
	kill `ps -ax | grep ssh | grep $ES_HOST | awk '{print $1}'`
	shift
fi
trap terminate INT
echo "$SSH -L 8443:$ES_HOST:443 $BASTION &"
$SSH -L 8443:$ES_HOST:443 $BASTION &
echo "wait $(jobs -p)"
wait $(jobs -p) 
