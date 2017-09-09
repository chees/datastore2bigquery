#!/bin/bash

# Abort on error:
set -euo pipefail

NC=$(tput sgr 0) # No Color
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

if [ "$#" == 0 ]; then
  echo "This script exports a Datastore kind to Cloud Storage, imports it into BigQuery and then deletes the Cloud Storage files."
  echo "Usage  : $0 <PROJECT> <KIND> [BQDATASET]"
  echo "Example: $0 code-cooking Food"
  exit 1
fi
PROJECT=$1
if [ -n "${2:-}" ]; then KIND=$2; else echo "${RED}Please also specify a KIND$NC"; exit 1; fi
if [ -n "${3:-}" ]; then BQDATASET=$3; else BQDATASET=datastore; fi


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
