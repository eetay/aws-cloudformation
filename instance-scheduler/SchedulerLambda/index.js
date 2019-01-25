var AWS = require('aws-sdk');
//AWS.config.update({region: 'REGION'});
var ec2 = new AWS.EC2({apiVersion: '2016-11-15'});

function ec2op(op, params) {
  if (!params.InstanceIds) return Promise.resolve('nothing to do');
  return new Promise( (resolve, reject) => {
    ec2[op](params, function(err, data) {
      if (err && err.code === 'DryRunOperation') {
        params.DryRun = false;
        ec2.stopInstances(params, function(err, data) {
            if (err) {
              reject(err);
            } else if (data) {
              resolve(data.StoppingInstances)
            }
        })
      } else {
        reject(`You don't have permission to ${op} ${params.InstanceIds}`)
      }
    })
  })
}

exports.handler = async (event, context) => {
    let result = {
      'START': await ec2op('startInstances', { InstanceIds: event.START, DryRun: true}),
      'STOP': await ec2op('stopInstances', { InstanceIds: event.STOP, DryRun: true})
    }
    const response = {
        statusCode: 200,
        body: result
    }
    return response
}

