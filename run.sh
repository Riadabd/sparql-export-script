#!/bin/bash
# NOTE: Before usage, make sure executable permission are set `chmod +x <name>.sh`

SPARQL_ENDPOINT='http://localhost:8890/sparql'
FAILED=0

while :; do
  case $1 in
    --sparql-endpoint)
      if [ "$2" ]; then
        SPARQL_ENDPOINT=$2
      fi
      ;;
    # End of all options.
    --)
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    # Default case: No more options, so break out of the loop.
    *)
      break
  esac
  shift
done

mkdir -p diff
rm -rf diff/*export.ttl

for path in queries/*.sparql;do
    filename=$(basename "$path" .sparql)
    query=$(cat "$path")
    echo "[INFO] Generating export for $filename ..."
    if curl --fail -X POST "$SPARQL_ENDPOINT" \
      -H 'Accept: text/plain' \
      --form-string "query=$query" >> diff/export.ttl; then
      echo "[INFO] Finished export for $filename!"
    else
      echo "[ERROR] export for $filename Failed!"
      FAILED+=1
    fi;
    echo "================================================================================"
done
echo "[INFO] Export Done! You can find your export in diff/export.ttl"
if ((FAILED > 0)); then
  echo "[WARNING] some queries failed, export incomplete ..."
fi;