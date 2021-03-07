# Terraform Jenins Service Installation
## In this k3 kubernetes branch there is a terraform main.tf file that will deploy a similar jenkins service using a persistent volume claim on the k3s nodes local-path provisioner.
### Installing terraform on Ubuntu 20.04 k3s kubernetes node
#### Step 1: Installing Terraform
Follow the steps on this website to install Terraform using an APT repository: https://www.terraform.io/docs/cli/install/apt.html
#### Step 2: Configure the KUBECONFIG environment on your k3s kubernetes node for Terraform
Terraform needs the certificate-autohority-data, the client-certificate-data and the local host address to execute kubnetes commands on your local k3s node. These items are found in your ~/:.kube directory, where ~ is your home directory.  You will need to create ~/.kube/config file by coping the /etc/rancher/k3s/k3s.yaml to ~/.kube/config: "cp /etc/rancher/k3s/k3s.yaml ~/.kube/config.  Your ~/.kube/config file should look look similar to this:
```apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJkakNDQVIyZ0F3SUJBZ0lCQURBS0JnZ3Foa2pPUFFRREFqQWpNU0V3SHdZRFZRUURE ... Part of the data has been left out intentionally
    server: https://127.0.0.1:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJrVENDQVRlZ0F3SUJBZ0lJTWdLQ3BrWUhRa0F3Q2dZSUtvWkl6ajBFQXdJd0l6RWhNQjhHQTFVRUF3d1kKYXpOekxXTnNhV1Z1ZEMxa ... Part of the data has been left out intentionally
    client-key-data: LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSU94cGcyUC9aYnNTM1VyM2I3K0 .. Part of the data has been left out intentionally.
```
#### Step 2: 
### main.tf file
#### 1. config_path section
