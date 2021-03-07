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
```k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl get pods n jenkins-tf
Error from server (NotFound): pods "n" not found
Error from server (NotFound): pods "jenkins-tf" not found
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl get pods -n jenkins-tf
NAME                                  READY   STATUS    RESTARTS   AGE
jenkins-deployment-54bdb4b544-rjb9j   1/1     Running   0          14m
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl -exec -it /bin/bash jenkins-deployment-54bdb4b544-rjb9j
Error: flags cannot be placed before plugin name: -exec
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl -exec /bin/bash jenkins-deployment-54bdb4b544-rjb9j
Error: flags cannot be placed before plugin name: -exec
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl exec /bin/bash jenkins-deployment-54bdb4b544-rjb9j
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
error: arguments in resource/name form may not have more than one slash
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl exec "/bin/bash" jenkins-deployment-54bdb4b544-rjb9j
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
error: arguments in resource/name form may not have more than one slash
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl exec -it -n jenkins-tf jenkins-deployment-54bdb4b544-rjb9j bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
jenkins@jenkins-deployment-54bdb4b544-rjb9j:/$ cd /var/jenkins_home/secrets/initialAdminPassword
bash: cd: /var/jenkins_home/secrets/initialAdminPassword: Not a directory
jenkins@jenkins-deployment-54bdb4b544-rjb9j:/$ cd /var/jenkins_home/secrets/
jenkins@jenkins-deployment-54bdb4b544-rjb9j:~/secrets$ ls
filepath-filters.d		 org.jenkinsci.main.modules.instance_identity.InstanceIdentity.KEY
initialAdminPassword		 slave-to-master-security-kill-switch
jenkins.model.Jenkins.crumbSalt  whitelisted-callables.d
master.key
jenkins@jenkins-deployment-54bdb4b544-rjb9j:~/secrets$ cat initialAdminPassword 
5f50268d094d458db944ab4e8a04fd64
jenkins@jenkins-deployment-54bdb4b544-rjb9j:~/secrets$ exit
exit
k3-admin@k3-server:~/jenkins/terraform-jenkins$ cd ..
k3-admin@k3-server:~/jenkins$ ls
config-map.yaml  jenkins-deploy.yaml  jenkins-service.yaml     pod.yaml          pvc.yaml
data             jenkins-pvc.yaml     local-path-storage.yaml  pvc-jenkins.yaml  terraform-jenkins
k3-admin@k3-server:~/jenkins$ vi jenkins-deploy.yaml
k3-admin@k3-server:~/jenkins$ kubernetes jenkins deployment https
Command 'kubernetes' not found, but can be installed with:
sudo apt install kubernetes
k3-admin@k3-server:~/jenkins$ cd terraform-jenkins/
k3-admin@k3-server:~/jenkins/terraform-jenkins$ ls
main.tf  terraform.tfstate  terraform.tfstate.backup
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git init
Initialized empty Git repository in /home/k3-admin/jenkins/terraform-jenkins/.git/
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git add main.tf
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   main.tf

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.terraform.lock.hcl
	.terraform/
	.twistlock/
	terraform.tfstate
	terraform.tfstate.backup

k3-admin@k3-server:~/jenkins/terraform-jenkins$ get commit -m "This terraform file will deploy a jenkins service on a k3s kuberntes node that is using the k3s local-path provisioner"
Command 'get' not found, but there are 18 similar ones.
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git commit -m "This terraform file will deploy a jenkins service on a k3s kuberntes node that is using the k3s local-path provisioner"
[master (root-commit) bf9cbac] This terraform file will deploy a jenkins service on a k3s kuberntes node that is using the k3s local-path provisioner
 1 file changed, 98 insertions(+)
 create mode 100644 main.tf
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.terraform.lock.hcl
	.terraform/
	.twistlock/
	terraform.tfstate
	terraform.tfstate.backup

nothing added to commit but untracked files present (use "git add" to track)
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git remote add origin https://github.com/yankeeprof/k3.git
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git checkout -b terraform-jenkins
Switched to a new branch 'terraform-jenkins'
k3-admin@k3-server:~/jenkins/terraform-jenkins$ git  push -u origin terraform-jenkins
Username for 'https://github.com': yankeeprof
Password for 'https://yankeeprof@github.com': 
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Delta compression using up to 2 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 841 bytes | 841.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
remote: 
remote: Create a pull request for 'terraform-jenkins' on GitHub by visiting:
remote:      https://github.com/yankeeprof/k3/pull/new/terraform-jenkins
remote: 
To https://github.com/yankeeprof/k3.git
 * [new branch]      terraform-jenkins -> terraform-jenkins
Branch 'terraform-jenkins' set up to track remote branch 'terraform-jenkins' from 'origin'.
k3-admin@k3-server:~/jenkins/terraform-jenkins$ vi main.tf
k3-admin@k3-server:~/jenkins/terraform-jenkins$ cd 
k3-admin@k3-server:~$ cd .kube
k3-admin@k3-server:~/.kube$ ls
cache  config
k3-admin@k3-server:~/.kube$ vi config
k3-admin@k3-server:~/.kube$ cd ~/.kube
k3-admin@k3-server:~/.kube$ cd /etc/rancher/k3s
k3-admin@k3-server:/etc/rancher/k3s$ ls
k3s.yaml
k3-admin@k3-server:/etc/rancher/k3s$ vi config
k3-admin@k3-server:/etc/rancher/k3s$ cd ~/.kube
k3-admin@k3-server:~/.kube$ vi config
k3-admin@k3-server:~/.kube$ cd
k3-admin@k3-server:~$ ls
cluster-cert.txt  prisma_cloud                                   snap
jenkins           prisma_cloud_compute_edition_20_04_177.tar.gz  terraform
k3                sa-config                                      twistlock_console.tar.gz
nginx.yaml        sa.yml
k3-admin@k3-server:~$ cd jenkins
k3-admin@k3-server:~/jenkins$ cd terraform-jenkins/
k3-admin@k3-server:~/jenkins/terraform-jenkins$ vi main.tf
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl get resource
error: the server doesn't have a resource type "resource"
k3-admin@k3-server:~/jenkins/terraform-jenkins$ vi main.tf
k3-admin@k3-server:~/jenkins/terraform-jenkins$ kubectl get namespace
NAME                 STATUS   AGE
default              Active   38d
kube-system          Active   38d
kube-public          Active   38d
kube-node-lease      Active   38d
jenkins              Active   35d
local-path-storage   Active   35d
nginx                Active   16d
twistlock            Active   4d17h
jenkins-tf           Active   3d
k3-admin@k3-server:~/jenkins/terraform-jenkins$ vi main.tf

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
                                                                                1,1           Top
#### 1. The config_path section
This section tells Terraform where to find the KUBECONFIG environment config file on your k3s node.  The default path is ~/.kube/config.
#### 2. The kubernetes_namespace section
In this section terraform creates the kubernetes namespace: "jenkins-tf"
#### 3. The kubernetes_persistent_volume_claim section
In this section terraform creates the pvc named: "jenkins-claim" in the :namespace: "jenkins-tf".
