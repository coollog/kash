#!/usr/bin/env bash

POD_IMAGE=$1
POD_NAME=$(uuidgen)

cat k8s/krun-pod.yaml |
    sed -e "s/{POD_NAME}/${POD_NAME}/" |
    sed -e "s/{POD_IMAGE}/${POD_IMAGE}/" |
    kubectl apply -f -

echo "Running pod ${POD_NAME}..."
while [ $(kubectl get po ${POD_NAME} -o jsonpath="{.status.phase}") != "Running" ]
do
  sleep 1
done

kubectl attach -it ${POD_NAME} -c container
kubectl delete po ${POD_NAME}
