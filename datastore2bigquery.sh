#!/bin/bash

PROJECT=code-cooking
KIND=Food
BQDATASET=datastore

# Abort on error:
set -euo pipefail

NC=$(tput sgr 0) # No Color
GREEN=$(tput setaf 2)

GCSPATH=gs://$PROJECT.appspot.com/datastore-$KIND-`date -u +"%Y-%m-%dT%H:%M:%SZ"`

echo -e "${GREEN}Starting datastore export...$NC"
gcloud beta datastore export --kinds="$KIND" --project=$PROJECT $GCSPATH

echo -e "${GREEN}Creating BigQuery dataset...$NC"
bq mk -f $PROJECT:$BQDATASET

echo -e "${GREEN}Loading export into BigQuery...$NC"
bq load --source_format=DATASTORE_BACKUP $PROJECT:$BQDATASET.${KIND}_`date -u +"%Y%m%dT%H%M%SZ"` $GCSPATH/all_namespaces/kind_$KIND/all_namespaces_kind_$KIND.export_metadata

echo -e "${GREEN}Deleting backup files from Cloud Storage...$NC"
gsutil rm -r $GCSPATH

echo -e "${GREEN}Done$NC"
