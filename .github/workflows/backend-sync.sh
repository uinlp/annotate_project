#!/bin/bash
# Build docker image
docker build -t uinlp-backend .
# Tag docker image
docker tag uinlp-backend:latest $BACKEND_IMAGE_URI
# Push docker image
docker push $BACKEND_IMAGE_URI