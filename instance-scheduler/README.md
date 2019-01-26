# Instance Scheduler Lambda

A lambda function which is operated by cloudwatch events
all configured and deployed using cloudformation template




### Adding a new scheduling rule

In order to add a schedule, you edit the cloudformation.yaml
Add a ```AWS::Events::Rule``` and a matching ```AWS::Lambda::Permission```, like so:

```yaml
  MyScheduleRule: 
    Type: AWS::Events::Rule
    Properties: 
      Description: "Stop on 08:00 SUN-THU"
      ScheduleExpression: "cron(0 8 ? * SUN-THU *)"
      State: "ENABLED"
      Targets: 
        - 
          Arn: 
            Fn::GetAtt: 
              - "SchedulerLambda"
              - "Arn"
          Id: "SchedulerLambda"
          Input: '{"STOP":[{"Name":"tag:Name","Values":["bastion"]}]}'

  PermissionForMyScheduleRule: 
    Type: AWS::Lambda::Permission
    Properties: 
      FunctionName: 
        Ref: "SchedulerLambda"
      Action: "lambda:InvokeFunction"
      Principal: "events.amazonaws.com"
      SourceArn: 
        Fn::GetAtt: 
          - "MyScheduleRule"
          - "Arn"
```

[ScheduleExpression](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html) is AWS Cloudwatch expression

### Format of the action taken
The schedule action in the ```Input``` parameter is a JSON object containing either or both of "START"  and "STOP" keys, with value of each is a search filter for instances. Its format is identical to the [```Filters``` parameter](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html) of the DescribeInstances EC2 API.

example: stop all instances named 'bastion'
```json
{"STOP":[{"Name":"tag:Name","Values":["bastion"]}]}
```

example: stop multiple instances by ids
```json
{"START":[{"Name":"instance-id","Values":["i-0a380d20e66d974fe", "i-0a3801231deadbabe"]}]}
```

### deploy

after editing cloudformation.yaml to add your own rules
first time to create the stack and deploy function:
```sh
./deploy.sh create
./deploy.sh deploy
``` 

or 2nd time and on: 
```sh
./deploy.sh update
```
to update the cloudwatch rules
