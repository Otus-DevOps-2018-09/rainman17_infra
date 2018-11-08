#!/bin/bash

# Start VM 
gcloud compute instances create reddit-app\
  --boot-disk-size=12GB \
  --image-family=reddit-full \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
