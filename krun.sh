#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: ./krun.sh <IMAGE>"
fi

POD_IMAGE=$1
POD_NAME=$(uuidgen)

# Applies the Pod template.
cat k8s/krun-pod.yaml |
    sed -e "s/{POD_NAME}/${POD_NAME}/" |
    sed -e "s/{POD_IMAGE}/${POD_IMAGE}/" |
    kubectl apply -f -

echo "Running pod ${POD_NAME}..."

# Waits for the Pod to start running.
while [ $(kubectl get po ${POD_NAME} -o jsonpath="{.status.phase}") != "Running" ]
do
  sleep 1
done

# Attaches the to the Pod.
kubectl attach -it ${POD_NAME} -c container

# Cleans up the Pod.
kubectl delete po ${POD_NAME}
