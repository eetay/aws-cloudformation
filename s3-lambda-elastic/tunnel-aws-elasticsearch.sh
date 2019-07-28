#!/bin/bash
SSH="ssh -nNT -i ~/.ssh/OhioRegionKeypair.pem"
BASTION=ec2-user@ec2-52-14-190-167.us-east-2.compute.amazonaws.com
INSTANCE=vpc-index-a2ywdiz63je5667uhfupvuys5u.us-east-2.es.amazonaws.com
function terminate() {
	echo "Terminating SSHs: $(jobs -p)"
	kill $(jobs -p)
}
if [ "$1" == "--kill" ]; then
	kill `ps -ax | grep ssh | grep $INSTANCE | awk '{print $1}'`
	shift
fi
trap terminate INT
echo "$SSH -L 8443:$INSTANCE:443 $BASTION &"
$SSH -L 8443:$INSTANCE:443 $BASTION &
echo "wait $(jobs -p)"
wait $(jobs -p) 
