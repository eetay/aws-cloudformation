var AWS = require('aws-sdk');
//AWS.config.update({region: 'REGION'});
var ec2 = new AWS.EC2({apiVersion: '2016-11-15'});

function ec2op(op, params) {
  const OPS = {
    describeInstances: ec2.describeInstances,
    startInstances: ec2.startInstances,
    stopInstances: ec2.stopInstances
  }
  const VALIDATIONS = {
    describeInstances: params => Array.isArray(params.Filters),
    startInstances: params => Array.isArray(params.InstanceIds),
    stopInstances: params => Array.isArray(params.InstanceIds),
  }
  if (!OPS[op]) return Promise.reject(`Bad operation ${op}`)
  if (!(VALIDATIONS[op](params))) {
    return Promise.reject(`${op}: Bad params: ${JSON.stringify(params)}`)
  }
  // Execution
  return new Promise( (resolve, reject) => {
    ec2[op](params, function(err, data) {
      if (!params.DryRun) {
        resolve(data)
      } else if (err && err.code === 'DryRunOperation') {
        params.DryRun = false 
            ec2[op](params, function(err, data) {
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

