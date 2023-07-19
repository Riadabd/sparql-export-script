#!/bin/bash
# NOTE: Before usage, make sure executable permission are set `chmod +x <name>.sh`

# VAR. DEFAULT
FAILED=0
OUT_FOLDER="tmp/"
DEFAULT_EXPORT_FILENAME="export"
SPARQL_ENDPOINT='http://localhost:8890/sparql'

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

mkdir -p "$OUT_FOLDER"
rm -rf "$OUT_FOLDER"/*

for path in queries/*.sparql; do
    filename=$(basename "$path" .sparql)

    # Create a turtle file and its corresponding graph with the current timestamp
    current_date=$(date '+%Y%m%d%H%M%S')
    mkdir -p "$OUT_FOLDER"/"$current_date-$filename"
    export_ttl_filename="$current_date-$filename.ttl"
    export_graph_filename="$current_date-$filename.graph"

    query=$(cat "$path")
    echo "[INFO] Generating export for $filename ..."
    if curl --fail -X POST "$SPARQL_ENDPOINT" \
      -H 'Accept: text/plain' \
      --form-string "query=$query" >> "$OUT_FOLDER"/"$current_date-$filename"/"$export_ttl_filename"; then
      echo "[INFO] Finished export for $filename!"
      touch "$OUT_FOLDER/$current_date-$filename/$export_graph_filename"
      echo "[INFO] Created graph file for $filename!"
    else
      echo "[ERROR] Export for $filename failed!"
      FAILED+=1
    fi;
    echo "================================================================================"
done

echo "[INFO] Export done! You can find your export in $OUT_FOLDER/$current_date-$filename/"

if ((FAILED > 0)); then
  echo "[WARNING] $FAILED queries failed, export incomplete ..."
fi;