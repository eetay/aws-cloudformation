'use strict'
const { Client } = require('@elastic/elasticsearch')
const client = new Client({ node: `https://${process.env.DATABASE}` })

var AWS = require('aws-sdk')

const s3 = new AWS.S3();

async function processOne(s3op) {
    console.log('SOME S3 EVENT:',JSON.stringify(s3op))
    let bucketName = s3op.bucket.name
    let s3ObjectPath = s3op.object.key
    try {
        let result = await client.index({
            index: 'game-of-thrones',
            body: {
                path: s3ObjectPath,
                bucketName
            }
        })
        console.log('ES RESULT:', result)
    }
    catch (e) {
        console.log('ERROR', e)
    }
    return 1
}

exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        body: event,
    }
    await Promise.all( event.Records.map( record=>processOne(record.s3) ) )
    return response
}

