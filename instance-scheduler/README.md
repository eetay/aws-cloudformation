# Instance Scheduler

A simple AWS scheduler for starting and stoping AWS EC2 instances, based on lambda function which is triggered by scheduling rules defined as cloudwatch events. The deploying the scheduler as well as updating new a schedule uses cloudformation and is very simple to use.

The scheduler is specifically not using any database so it can be used with AWS free tier, totally free.

The scheduler supports identifying the EC2 instances via Filters, not just instance ID.

### Adding a new scheduling rule

In order to add a schedule, you edit the cloudformation.yaml
Add a ```AWS::Events::Rule``` and a matching ```AWS::Lambda::Permission``` objects, like so:

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

modify ```Description```, ```ScheduleExpression``` and ```Input``` as per below:

#### ScheduleExpression
[ScheduleExpression](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html) is AWS Cloudwatch expression

#### Input
The schedule action in the ```Input``` parameter is a JSON object containing either or both of "START"  and "STOP" keys, with value of each is a search filter for instances. Its format is identical to the [```Filters``` parameter](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html) of the DescribeInstances EC2 API.

example: stop all instances named 'bastion'
```json
{"STOP":[{"Name":"tag:Name","Values":["bastion"]}]}
```

example: start multiple instances by ids
```json
{"START":[{"Name":"instance-id","Values":["i-0a380d20e66d974fe", "i-0a3801231deadbabe"]}]}
```

### deploying and updating

after editing cloudformation.yaml to add your own rules
first time to create the stack and deploy function:
```sh
./deploy.sh create # create stack and deploy scheduling rules
./deploy.sh deploy # deploy the lambda function code
``` 

or 2nd time and on: 
```sh
./deploy.sh update # update scheduling rules
```
to update the cloudwatch rules
