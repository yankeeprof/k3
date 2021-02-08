# Rancher k3s Installation Setup and Jenkins Service Deployment on a k3s Node
## Overview 
The purpose of this document is to step you through installing k3 on an Ubuntu 20.04 virtual machine and deploying a Jenkins service on the k3 Kubernetes node with persistent local storage. Rancher k3s can be very easily installed on any Linux distribution. This installation will use the docker container engine and will will install local storage using the local-path-provisioner container.  The intitial k3 installation will create a single node kubernetes cluster.  A Jenkins service will be deployed on this pod using persistent local path storage.  Documentation sources for this installation are as follows:

https://rancher.com/docs/k3s/latest/en/quick-start/

https://rancher.com/docs/k3s/latest/en/advanced/

https://github.com/rancher/local-path-provisioner/blob/master/README.md#usage
## k3s Installation Steps
