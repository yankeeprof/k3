# Terraform Jenins Service Installation
## In this k3 kubernetes branch there is a terraform main.tf file that will deploy a similar jenkins service using a persistent volume claim on the k3s nodes local-path provisioner.
### Installing terraform on Ubuntu 20.04 k3s kubernetes node
#### Step 1: Installing Terraform
Follow the steps on this website to install Terraform using an APT repository: https://www.terraform.io/docs/cli/install/apt.html
#### Step 2: Configure Terraform's KUBECONFIG environment on your k3s kubernetes node
Terraform needs the certificate-autohority-data, the client-certificate-data and the local host address to execute kubnetes commands on your local k3s node. These items are found in your k3 node's home .kube directory's config file "~/.kube/config".  You will need to create a ~/.kube/config file by coping the /etc/rancher/k3s/k3s.yaml to ~/.kube/config: "cp /etc/rancher/k3s/k3s.yaml ~/.kube/config.  The contents of your ~/.kube/config file should look look similar to this:
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRU ... Part of the data has been left out intentionally
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
    client-certificate-data: LS0tLS1CRU ... Part of the data has been left out intentionally
    client-key-data: LS0tLS1CRUdJTiBFQy .. Part of the data has been left out intentionally.
```
#### Step 2: 
### The main.tf file
```
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}
resource "kubernetes_namespace" "jenkins_terraform" {
  metadata {
    name = "jenkins-tf"
  }
}

resource "kubernetes_persistent_volume_claim" "claim" {
  metadata {
    name = "jenkins-claim"
    namespace = "jenkins-tf"
    labels = {
    managedby = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "local-path"
  }
  depends_on = [kubernetes_namespace.jenkins_terraform
  ]
}


resource "kubernetes_deployment" "jenkins-tf" {
  depends_on = [
    kubernetes_namespace.jenkins_terraform
  ]
  metadata {
    name      = "jenkins-deployment"
    namespace = "jenkins-tf"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkinsapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkinsapp"
        }
      }
      template {
      metadata {
        labels = {
          app = "jenkinsapp"
        }
      }
      spec {
        container {
          image = "jenkins/jenkins:latest"
          name  = "jenkins-container"
          port {
            container_port = 8080
          }
          volume_mount {
            name       = "jenkins-persistent-storage"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "jenkins-persistent-storage"
          persistent_volume_claim {
            claim_name = "jenkins-claim"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins-tf" {
  depends_on = [
    kubernetes_deployment.jenkins-tf
  ]

  metadata {
    name      = "jenkinsapp"
    namespace = "jenkins-tf"
  }
  spec {
    selector = {
      app = "jenkinsapp"
    }
    type = "NodePort"
    port {
      node_port   = 31080
      port        = 8080
      target_port = 8080
    }
  }
}
```
#### 1. The config_path section
This section tells Terraform where to find the KUBECONFIG environment config file on your k3s node.  The default path is ~/.kube/config.
#### 2. The kubernetes_namespace section
In this section terraform creates the kubernetes namespace: "jenkins-tf"
#### 3. The kubernetes_persistent_volume_claim section
In this section terraform creates the pvc named: "jenkins-claim" in the :namespace: "jenkins-tf".
