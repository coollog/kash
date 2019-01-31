```bash
kubectl apply -f k8s/krun-namespace.yaml
```

```bash
kubectl config get-contexts
export GKE_CONTEXT=???
```

```bash
kubectl config set-context krun --namespace=krun \
    --cluster=${GKE_CONTEXT} --user=${GKE_CONTEXT}
kubectl config use-context krun
```

```bash
gcloud compute disks create --size=10GB --zone=us-west1-c krun-nfs
```

```bash
kubectl apply -f k8s/nfs-server.yaml
kubectl apply -f k8s/nfs-volume.yaml
```

```bash
kubectl apply -f k8s/test-pods.yaml
```
```bash
kubectl attach -it po/test1
kubectl attach -it po/test2
```

See pods by node:

```bash
kubectl get pods -o wide
```