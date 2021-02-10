# Rancher k3s Kubernetes Installation Setup and Jenkins Service Deployment on a k3s Node
## Overview 
The purpose of this document is to step you through installing k3 on an Ubuntu 20.04 virtual machine and deploying a Jenkins service on the k3 Kubernetes node with persistent local storage. Rancher k3s kubernetes can be very easily installed on any Linux distribution. This installation will use the docker container engine and will will install local storage using the local-path-provisioner container. The compute resources assigned the Ubuntu VM are as follows: vcpu's: 2; mem: 4GB; disc storage 30GB. The intitial k3 installation will create a single node kubernetes cluster.  A Jenkins service will be deployed on this pod using persistent local path storage.  Documentation sources for this installation are as follows:

https://rancher.com/docs/k3s/latest/en/quick-start/

https://rancher.com/docs/k3s/latest/en/advanced/

https://github.com/rancher/local-path-provisioner/blob/master/README.md#usage
## k3s Installation Steps
#### Step 1: Install docker on your Linux VM
You can install docker on your VM by following the directions on the docker installation Website or you can install docker by using Rancher's installation script.

Follow the directions on this docker website to install docker on Ubuntu: https://docs.docker.com/engine/install/ubuntu/ 

To install docker using Rancher's installation script, pease enter the following command in your bash terminal:

**"curl https://releases.rancher.com/install-docker/20.10.sh | sh"**
#### Step 2: Install k3s with docker option using Rancher install script
Enter the following command in your bash terminal:
**"curl -sfL https://get.k3s.io | sh -s - --docker"**
#### Step 3 (Optional): Create a kubectl alias for "sudo k3s kubectl"
In order to execute kubectl commands on your Ubuntu VM, you will need to enter "sudo k3s kubectl".  You may want to shorten this to just "kubectl" by creating an alias.  You can create a temporary alias by entering the following command in your bash terminal: **"alias kubectl="sudo k3s kubectl"** If you want your alias to persist after reboot then you will need to add it to your .bashrc file in your home directory. **$ vim ~/.bashrc**
#### Step 4: Create Persistent Local Storage for k3s Kubernetes
Creating a persistent local storage environment for your Kubernetes pods and deployments is not an easy task requiring you to map local directories to create a storage class that you can use to create persistent volume claims and persistent volumes for your pods and deployments.  Ranger k3s has made this task simple by using a local-path-provisioner container.  You just apply the local-path-storage.yaml that is in this repository by entering the following command in your k3s node's bash terminal: **"kubectl apply -f local-storage-path.yaml"**. You can check to make sure your provisioner container entering the following command in your bash terminal: **"kubectl get pods -n local-path-storage"**.  You should see your local-path-provisioner container running.
``` 
k3-admin@k3-server:~/jenkins$ kubectl get pods -n local-path-storage
NAME                                      READY   STATUS    RESTARTS   AGE
local-path-provisioner-5696dbb894-t7hkj   1/1     Running   0          9d
```
#### Step 5: Create a Jenkins persistent volume claim for your Jenkins deployment

