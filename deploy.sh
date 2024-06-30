#!/bin/bash

# Get the name of the registry container 
REGISTRY_NAME=juaneshgcloud

# Stop the registry before deleting images
docker stop $REGISTRY_NAME

# Get the list of tags for the image
IMAGE_TAGS=$(curl -s -X GET http://localhost:5000/v2/juanberger/tags/list | jq -r '.tags[]')

# Loop over the tags and delete each one
for tag in $IMAGE_TAGS; do
  # Get the digest for the image:tag
  DIGEST=$(curl -I -s -X GET http://localhost:5000/v2/juanberger/manifests/$tag | grep Docker-Content-Digest | awk '{print $2}' | tr -d $'\r')

  # Delete the image:tag
  curl -X DELETE http://localhost:5000/v2/juanberger/manifests/$DIGEST
done

# Garbage collect the deleted image data from the registry
docker exec $REGISTRY_NAME bin/registry garbage-collect /etc/docker/registry/config.yml

# Start the registry back up
docker start $REGISTRY_NAME

# Delete the old docker image
docker rmi localhost:5000/juanberger:latest

# Build the docker image
docker build -t localhost:5000/juanberger:latest .

# Push the docker image to the local registry
docker push localhost:5000/juanberger:latest

# Delete the old deployment
kubectl delete deployment juanberger-deployment

# Delete the old service
kubectl delete service juanberger-service

# Apply the Kubernetes deployment
kubectl apply -f deployment.yaml

# Apply the Kubernetes service
kubectl apply -f service.yaml

# Get SVC
kubectl get svc
