#!/bin/bash
# NOTE: Make sure executable permissions are set (`chmod +x <name>.sh`)

# Variable defaults
FAILED=0
OUT_FOLDER="tmp"

SPARQL_ENDPOINT="http://localhost:8890/sparql"

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
rm -rf "${OUT_FOLDER:?}"/*

mapfile -t sparql_queries < <(find queries/ -maxdepth 1 -name "*.sparql")
if [ ${#sparql_queries[@]} -eq 0 ]; then
  echo "[Error] There are no queries inside queries/"
  exit 1
fi

for path in queries/*.sparql; do
  filename=$(basename "$path" .sparql)

  # Create a turtle file with the current timestamp
  current_date=$(date '+%Y%m%d%H%M%S')
  export_ttl_filename="$current_date-$filename.ttl"

  query=$(cat "$path")
  echo "[INFO] Generating export for $filename ..."
  if curl --fail -X POST "$SPARQL_ENDPOINT" \
    -H 'Accept: text/plain' \
    --form-string "query=$query" >> "$OUT_FOLDER"/"$export_ttl_filename"; then

    echo "[INFO] Finished export for $filename!"
  else
    echo "[ERROR] Export for $filename failed!"
    FAILED=$((FAILED + 1))
  fi;
  echo -e "================================================================================\n"
done

if ((FAILED > 0)); then
  echo "[WARNING] $FAILED query(ies) failed, export incomplete ..."
else
  echo "[INFO] Export done! You can find your export(s) in $OUT_FOLDER."
fi
