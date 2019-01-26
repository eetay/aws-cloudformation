var AWS = require('aws-sdk');
//AWS.config.update({region: 'REGION'});
var ec2 = new AWS.EC2({apiVersion: '2016-11-15'});

function ec2op(op, params) {
  if (['startInstances', 'stopInstances'].includes(op) && !(Array.isArray(params.InstanceIds) && params.InstanceIds.length>0)) {
    return Promise.resolve(`${op}: nothing to do: ${JSON.stringify(params)}`)
  }
  return new Promise( (resolve, reject) => {
    ec2[op](params, function(err, data) {
      if (!params.DryRun) {
        resolve(data)
      } else if (err && err.code === 'DryRunOperation') {
        params.DryRun = false;
        ec2.stopInstances(params, function(err, data) {
            if (err) {
              reject(err);
            } else if (data) {
              resolve(data)
            }
        })
      } else {
        reject(`You don't have permission to ${op} ${JSON.stringify(params)}`)
      }
    })
  })
}

let instancesToIds = instances => instances.Reservations.reduce(
  (allIds, instances) => instances.Instances.reduce( 
    (ids, instance) => { 
      ids.push(instance.InstanceId)
      return ids
    }, allIds),
  []
)

let findInstances = filters => ec2op('describeInstances', { Filters: filters, DryRun: false })

exports.handler = async (event, context) => {
    let stopInstances = event.STOP && instancesToIds(await findInstances(event.STOP))
    let startInstances = event.START && instancesToIds(await findInstances(event.START))
    let result = {
      'START': startInstances && await ec2op('startInstances', { InstanceIds: startInstances, DryRun: true }),
      'STOP': stopInstances && await ec2op('stopInstances', { InstanceIds: stopInstances, DryRun: true }),
      stopInstances,
      startInstances
    }
    const response = {
        statusCode: 200,
        body: result
    }
    return response
}

