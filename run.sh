#!/bin/bash
# NOTE: Make sure executable permission are set (`chmod +x <name>.sh`)

# Variable defaults
FAILED=0
OUT_FOLDER="tmp/"

SPARQL_ENDPOINT="http://localhost:8890/sparql"

WRITE_TEMP_GRAPH=false
TEMP_GRAPH="http://graphs/temp"

while :; do
  case $1 in
    --sparql-endpoint)
       if [ -z "$2" ] || [[ "$2" == -* ]]; then
        echo "[Error] --sparql-endpoint option requires a value"
        exit 1
      fi
      SPARQL_ENDPOINT="$2"
      shift 1
      ;;
    --write-temp-graphs)
      if [ -z "$2" ] || [[ "$2" == -* ]]; then
        echo "[Error] --write-temp-graphs option requires a value"
        exit 1
      fi
      TEMP_GRAPH="$2"
      WRITE_TEMP_GRAPH=true
      shift 1
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    # Default case: No more options, so break out of the loop
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

      # This snippet assumes the sparql filename is of the format "{}-{}-{}-{}.sparql"
      # where the number of dashes is not fixed, and the string after the final dash is the name
      # of the target data type.
      if [ "$WRITE_TEMP_GRAPH" = true ] ; then
        echo "$TEMP_GRAPH/$(echo $filename | awk -F- '{print $NF}')" >> "$OUT_FOLDER/$current_date-$filename/$export_graph_filename"
      fi
    else
      echo "[ERROR] Export for $filename failed!"
      FAILED+=1
    fi;
    echo -e "================================================================================\n"
done

echo "[INFO] Export done! You can find your export(s) in $OUT_FOLDER"

if ((FAILED > 0)); then
  echo "[WARNING] $FAILED queries failed, export incomplete ..."
fi;