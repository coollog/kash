a simple interface to run bash across multiple machines

NFS for filesystem backing
shared filesystem



Cluster setup:

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

Run:

```bash
./krun bash
./krun python
```

Shared filesystem at /mnt

See pods by node:

```bash
kubectl get pods -o wide
```