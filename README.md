# kash - bash for Kubernetes

**Note: This is an experimental prototype. Do NOT use for production.**

Run bash in your Kubernetes cluster with a shared file system. Use your Kubernetes cluster like a simple distributed operating system where Kubernetes is just a process scheduler.

## What does this do

*To set up your own kash-enabled cluster, see **Cluster setup** below.*

Start up a bash instance with:

```bash
$ ./kash bash
```

Start up more bash instances on your cluster:

```bash
$ ./kash bash
```

`kash` will have Kubernetes try to distribute the bash instances across the available nodes. Every bash instance shares the same file system so **it feels like you are working on just one machine** except you are actually running bash across a cluster of machines.

You can see if the pods are distributed evenly across nodes with:

```bash
kubectl get pods -o wide
```

*An alternate name could be BUG (bash using GKE) so you could run it by calling `./bug bash`.*

## How it works

`kash` uses a Network File System to share the persistent disk across Pods running in multiple nodes. The Pods are also set to distribute across the nodes with anti-affinity towards other `kash` Pods. The shared file system is mounted at `kash`. `/kash/.bashrc` is the location of the `bashrc` and bash history is also shared among instances.

## Example - calculate PI

First, use `kash` to copy the `examples/calculatepi/*.py` scripts into `/kash/*.py`. 

Then, in one window, run:

```bash
$ ./kash python
bash# mkdir trials
bash# ./display_pi trials
```

In another window, run:

```bash
$ ./kash python
bash# ./run_trials trials/$RANDOM
```

Watch as the trials come in and the estimated PI is displayed.

Try running some more trial instances, which would distribute the workload across the cluster:

```bash
$ ./kash python
bash# ./run_trials trials/$RANDOM
```

## Cluster setup

### Set up kubectl

You can view your GKE clusters with:

```bash
gcloud container clusters list
```

Set `GKE_NAME` to the name of the cluster you want to use and `GKE_ZONE` to the zone of that cluster: 

```bash
export GKE_NAME=??? (ie. name of cluster)
export GKE_ZONE=??? (eg. us-west1-c)
```

Give `kubectl` credentials to control that cluster:

```bash
gcloud container clusters get-credentials ${GKE_NAME} --zone=${GKE_ZONE}
```

Create a `kash` namespace and have `kubectl` use that namespace:

```bash
export GKE_CONTEXT=$(kubectl config current-context)
kubectl apply -f k8s/kash-namespace.yaml
kubectl config set-context kash --namespace=kash \
    --cluster=${GKE_CONTEXT} --user=${GKE_CONTEXT}
kubectl config use-context kash
```

### Set up the shared persistent disk

Create a GCE persistent disk to use as the shared disk. Change `KASH_DISK_SIZE` to your desired size (in GB).

```bash
export KASH_DISK_SIZE=10
gcloud compute disks create --size=${KASH_DISK_SIZE}GB --zone=${GKE_ZONE} kash-nfs
```

Run the NFS server:

```bash
kubectl apply -f k8s/nfs-server.yaml
kubectl apply -f k8s/nfs-volume.yaml
```
