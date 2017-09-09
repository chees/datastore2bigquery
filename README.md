# Export Google Datastore to BigQuery

This script exports a Datastore kind to Cloud Storage, imports it into BigQuery and then deletes the Cloud Storage files.

Usage:

    ./datastore2bigquery.sh <PROJECT> <KIND> [BQDATASET]`

Example:

    ./datastore2bigquery.sh code-cooking Food
