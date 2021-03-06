# kubernetes-demo-cluster

Setup and run a multi-node Kubernetes cluster locally with the following specs:

* Nodes: 1 master, 2 worker (ubuntu 18.04)
* Kubernetes 1.19.6
* CNI: [Calico](https://docs.projectcalico.org/getting-started/kubernetes/) v3.17

Motivation: I needed a repeatable local Kubernetes environment to prepare for [CKA](https://www.cncf.io/certification/cka/) exam.


### Pre-requisites

 * **[Vagrant 2.2.9+](https://www.vagrantup.com)**
 * **[VirtualBox 6.1.2+](https://www.virtualbox.org)**
 * **[kubectl 1.19+](https://kubernetes.io/docs/tasks/tools/install-kubectl/)** (if you want to operate the cluster from your machine)

### Installation

To provision the cluster run:

    vagrant up


Verify the cluster (`.cache` directory will be created under `kubernetes-demo-cluster/` in the previous step)

    kubectl get nodes --kubeconfig=.cache/k8s-config.yaml

    NAME       STATUS   ROLES    AGE     VERSION
    master-0   Ready    master   4m14s   v1.19.6
    worker-1   Ready    <none>   2m24s   v1.19.6
    worker-2   Ready    <none>   40s     v1.19.6

#### Optional:
Deploy [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/):

    kubectl apply -f resources/base/nginx-ingress.yaml --kubeconfig=.cache/k8s-config.yaml

Deploy [metrics-server](https://github.com/kubernetes-sigs/metrics-server) (for `kubectl top` commands):

    kubectl apply -f resources/base/metrics-server.yaml --kubeconfig=.cache/k8s-config.yaml

### Clean-up

Execute the following command to remove the virtual machines created for the Kubernetes cluster.

    vagrant destroy -f


### Tips

* To install a different Kubernetes version update `K8S_VERSION` in `node/provision_node.sh`
* The number of worker nodes to provision is configured by `WORKERS` constant in `Vagrantfile`
* You can delete individual workers, e.g. `vagrant destroy worker-2 -f`
* Every node will have this directory mounted to `/vagrant`
* CKA exam resources:
  * https://github.com/walidshaari/Kubernetes-Certified-Administrator
  * https://github.com/StenlyTU/K8s-training-official
  * https://rx-m.com/cka-online-training/
