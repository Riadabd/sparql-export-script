## Sparql Export Script

### Usage

Place the [`CONSTRUCT`](https://www.w3.org/TR/rdf-sparql-query/#construct) queries you would like to be executed in the `/queries` directory.

Run the script:
```
run.sh --sparql-endpoint <url> --write-temp-graph
```
> **Note:**
> * The sparql-endpoint is set to http://localhost:8890/sparql by default.
> * `--write-temp-graph` takes no values and is used to write custom temp graph names inside `.graph` files or to keep them empty.