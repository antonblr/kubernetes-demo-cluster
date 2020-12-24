# kubernetes-demo-cluster

Setup and run a multi-node Kubernetes cluster locally with the following specs:

* Nodes: 1 master, 2 worker (ubuntu 18.04)
* Kubernetes 1.18.13 (to practice upgrade)
* CNI: [Calico](https://docs.projectcalico.org/getting-started/kubernetes/) v3.17

Motivation: I needed a repeatable local Kubernetes environment to prepare for [CKA](https://www.cncf.io/certification/cka/) exam.


### Pre-requisites

 * **[Vagrant 2.2.9+](https://www.vagrantup.com)**
 * **[VirtualBox 6.1.2+](https://www.virtualbox.org)**

### Installation

To provision the cluster run:

    vagrant up


Verify the cluster (`.cache` directory will be created on the host during the previous step)

    kubectl get nodes --kubeconfig=.cache/k8s-config.yaml

    NAME       STATUS   ROLES    AGE     VERSION
    master-0   Ready    master   4m31s   v1.18.13
    worker-1   Ready    <none>   2m36s   v1.18.13
    worker-2   Ready    <none>   47s     v1.18.13

#### Optional:
Deploy [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/):

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
* CKA exam resource:
  * https://github.com/walidshaari/Kubernetes-Certified-Administrator
  * https://github.com/StenlyTU/K8s-training-official
  * https://rx-m.com/cka-online-training/
