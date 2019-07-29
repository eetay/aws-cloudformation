# S3 bucket which triggers a Lambda for indexing, which then updates index in elasticsearch

## Installation

1. Setup aws-cli

2. Create file named 'config' with following content
```bash
STACK=HRTFDemoStack
S3TEMPLATESBUCKET=some-preconfigured-s3-bucket-for-cloudformation-templates
```

3. Create the stack
```bash
./stackctl.sh create
```

## Update the stack

```bash
./stackctl.sh update
```

## Deploy lambda code
```bash
./stackctl.sh deploy IndexingLambda
```

# Access indexing information using kibana UI
Tunnel the elasticsearch to localhost, and launch browser

```bash
./tunnel-aws-elasticsearch.sh &
firefox https://localhost:9200/_plugin/kibana
```

