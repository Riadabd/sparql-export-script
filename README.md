## Sparql Export Script

### Usage

Place the [`CONSTRUCT`](https://www.w3.org/TR/rdf-sparql-query/#construct) queries you'd like to be run into the `/queries` directory.

Run the script:
```shell
run.sh --sparql-endpoint <url>
```
> **Note:** by default the sparql-endpoint is set to http://localhost:8890/sparql