# S3 bucket which triggers a Lambda for indexing, which then updates index in elasticsearch

## create or update stack

```bash
./stackctl.sh create
./stackctl.sh update
```

## Deploy lambda code
```bash
./stackctl.sh deploy IndexingLambda
```

# kibana UI
Tunnel the elasticsearch to localhost, and launch browser

```bash
./tunnel-aws-elasticsearch.sh &
firefox https://localhost:9200/_plugin/kibana
```
