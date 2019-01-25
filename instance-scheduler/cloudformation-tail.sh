#if [ -z "$AWS_EXEC" ]; then source ./aws-exec.sh ""; fi
cloudformation_tail() {
  local stackName="$1"
  local lastEvent
  local lastEventId
  local stackStatus=$(aws cloudformation describe-stacks --stack $stackName --query 'Stacks[0].StackStatus' | sed 's/"//g')

  until \
	[ "$stackStatus" = "CREATE_COMPLETE" ] \
	|| [ "$stackStatus" = "CREATE_FAILED" ] \
	|| [ "$stackStatus" = "DELETE_COMPLETE" ] \
	|| [ "$stackStatus" = "DELETE_FAILED" ] \
	|| [ "$stackStatus" = "ROLLBACK_COMPLETE" ] \
	|| [ "$stackStatus" = "ROLLBACK_FAILED" ] \
	|| [ "$stackStatus" = "UPDATE_COMPLETE" ] \
	|| [ "$stackStatus" = "UPDATE_ROLLBACK_COMPLETE" ] \
	|| [ "$stackStatus" = "UPDATE_ROLLBACK_FAILED" ]; do

   	LastEvent=$(aws cloudformation describe-stack-events --stack $stackName --query 'StackEvents[].{ EventId: EventId, LogicalResourceId:LogicalResourceId, ResourceType:ResourceType, ResourceStatus:ResourceStatus, Timestamp: Timestamp }[0]' --max-items 1  | grep -v '[{}]' | sed 's/": /=/g;s/,$//;s/^ *"//')
    eval "local $LastEvent"
  	if [ "$EventId" != "$LastEventId" ]; then
  		LastEventId=$EventId
      echo -ne "\\r"
  		echo "$Timestamp $ResourceType $LogicalResourceId $ResourceStatus"
      #echo "EVID $EventId EVID"
      #echo "LAST $LastEvent LAST"
  	fi
  	sleep 3
    echo -n "."
    stackStatus=$(aws cloudformation describe-stacks --stack $stackName --query 'Stacks[0].StackStatus' | sed 's/"//g')
  done
  echo -ne "\\r"
  echo "Stack Status: $stackStatus"
}

cloudformation_tail $1
