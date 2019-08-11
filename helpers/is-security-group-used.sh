#!/bin/bash
SGLIST=$(./aws-exec.sh --silent aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' | sed 's/[^-a-z0-9,]//g' | sort | tr -d '\n')
#echo $SGLIST
if [ "$1" == "--where-used" ]; then
	WHERE_USED=",Description:Description,InstanceId:Attachment.InstanceId,PublicDns:Association.PublicDnsName"
else
	WHERE_USED=
fi
./aws-exec.sh --silent aws ec2 describe-network-interfaces --filters Name=group-id,Values=$SGLIST --query "NetworkInterfaces[*].{Id:Groups[0].GroupId,Name:Groups[0].GroupName$WHERE_USED}" --output=text | sort | uniq -c | tee sg-used.txt
awk -v "SGLIST=$SGLIST" '{ sub($1, "", SGLIST); } END { print SGLIST; }' sg-used.txt | sed 's/,,*/,/g' | tr ',' '\n' | tee sg-unused.txt | uniq -c | sed 's/ 1/ 0/'


