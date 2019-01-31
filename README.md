# krun - bash for Kubernetes

**Note: This is an experimental prototype. Do NOT use for production.**

Run bash in your Kubernetes cluster with a shared file system.

## What does this do

*To set up your own krun-enabled cluster, see **Cluster setup** below.*

Start up a bash instance with:

```bash
$ ./krun.sh bash
```

Start up more bash instances on your cluster:

```bash
$ ./krun.sh bash
```

`krun` will have Kubernetes try to distribute the bash instances across the available nodes. Every bash instance shares the same file system so **it feels like you are working on just one machine** except you are actually running bash across a cluster of machines.

You can see if the pods are distributed evenly across nodes with:

```bash
kubectl get pods -o wide
```

*An alternate name could be BUG (bash using GKE) so you could run it by calling `./bug bash`.*

## How it works

`krun` uses a Network File System to share the persistent disk across Pods running in multiple nodes. The Pods are also set to distribute across the nodes with anti-affinity towards other `krun` Pods. The shared file system is mounted at `krun`. `/krun/.bashrc` is the location of the `bashrc` and bash history is also shared among instances.

## Example - calculate PI

First, use `krun` to copy the `examples/calculatepi/*.py` scripts into `/krun/*.py`. 

Then, in one window, run:

```bash
$ ./krun.sh python
bash# mkdir trials
bash# python3 display_pi.py trials
```

In another window, run:

```bash
$ ./krun.sh python
bash# python3 run_trials.py trials/$RANDOM
```

Watch as the trials come in and the estimated PI is displayed.

Try running some more trial instances, which would distribute the workload across the cluster:

```bash
$ ./krun.sh python
bash# python3 run_trials.py trials/$RANDOM
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

Create a `krun` namespace and have `kubectl` use that namespace:

```bash
export GKE_CONTEXT=$(kubectl config current-context)
kubectl apply -f k8s/krun-namespace.yaml
kubectl config set-context krun --namespace=krun \
    --cluster=${GKE_CONTEXT} --user=${GKE_CONTEXT}
kubectl config use-context krun
```

### Set up the shared persistent disk

Create a GCE persistent disk to use as the shared disk. Change `KRUN_DISK_SIZE` to your desired size (in GB).

```bash
export KRUN_DISK_SIZE=10
gcloud compute disks create --size=${KRUN_DISK_SIZE}GB --zone=${GKE_ZONE} krun-nfs
```

Run the NFS server:

```bash
kubectl apply -f k8s/nfs-server.yaml
kubectl apply -f k8s/nfs-volume.yaml
```
