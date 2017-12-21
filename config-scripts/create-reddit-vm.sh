#!/bin/bash
gcloud compute instances create "reddit-app" \
--project "aerial-yeti-188613" \
--zone "europe-west1-b" \
--machine-type "f1-micro" \
--subnet "default" --maintenance-policy "MIGRATE" \
--tags "puma-server" --image-family reddit-full \
--boot-disk-size "10" --boot-disk-type "pd-standard"
