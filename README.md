# Rancher k3s Kubernetes Installation Setup and Jenkins Service Deployment on a k3s Node
## Overview 
The purpose of this document is to step you through installing k3s on an Ubuntu 20.04 virtual machine and deploying a Jenkins service on the k3s Kubernetes node with persistent local storage.  Rancher k3s kubernetes can be very easily installed on any Linux distribution and is great for home lab environment to better understand Kuberntes. This installation will use the docker container engine and will will install local storage using the local-path-provisioner container. The compute resources assigned the Ubuntu VM are as follows: vcpu's: 2; mem: 4GB; disc storage 30GB. The intitial k3s installation will create a single node kubernetes cluster.  A Jenkins service will be deployed on this pod using persistent local path storage.  Documentation sources for this installation are as follows:

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
Creating a persistent local storage environment for your Kubernetes pods and deployments is not an easy task requiring you to map local directories to create a storage class that you can use to create persistent volume claims and persistent volumes for your pods and deployments.  Ranger k3s has made this task simple by using a local-path-provisioner container.  You just apply the local-path-storage.yaml that is in this repository by entering the following command in your k3s node's bash terminal: **"kubectl apply -f local-storage-path.yaml"**. You can check to make sure your provisioner container is up and running by entering the following command in your bash terminal: **"kubectl get pods -n local-path-storage"**.  You should see your local-path-provisioner container running.
``` 
k3-admin@k3-server:~/jenkins$ kubectl get pods -n local-path-storage
NAME                                      READY   STATUS    RESTARTS   AGE
local-path-provisioner-5696dbb894-t7hkj   1/1     Running   0          9d
```
#### Step 5: Create a Jenkins persistent volume claim (pvc) for your Jenkins deployment
From the directory where you have saved your jenkins-pvc.yaml, apply the yaml by entering the following command in your k3s bash terminal: **"kubectl apply -f jenkins-pvc.yaml"**. This jenkins-pvc.yaml creates a persisent volume claim that uses your Kubernetes default namespace and reserves 10GB of local storage for your Jenkins deployment. You can change both of these values to suit your own environment.  You must however use "storageClassName: local-path" established by our local-path-storage-path.yaml in **Step 4** for any pvc you create for any deployment app or pod.    

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 10Gi
```
After applying your yaml you can check on its status by entering the following command in your bash terminal: **"kubectl get pvc"** and you should see your jenkins-pvc deployed with an UNBOUND status. When you create your Jenkins deployment app it will use this pvc and its status will change to BOUND. You will creaate your presistent volume for this pvc in your jenkins deployment yaml.
#### Step 6: Applying your Jenkins Deployment Yaml for Your Jenkins Service
From the directory where you saved your jenkins-deploy.yaml, you can apply your deployment by entering the following command in your k3s bash terminal: **"kubectl apply -f jenkins-deploy.yaml"**. In your jenkins-deploy.yaml file, you will deploy the latest Jenkins container image which will use container port 8080 for the Jenkins Web-UI.  You will map this container port to a node port in your service yaml so you can connect to the Web-UI from any client that is external to your k3s node.  In this deployment yaml you are creating your persistent volume (pv), named jenkins and mapping the pv to the pvc you cretead in **step 5**. Your Jenkins container will locally store, on your k3s node, all the data in its /var/jenkins_home diretory using the jenkins-pvc and  local storage class you set up in **Steps 4 & 5**.  As a result, all your Jenkins container configurations will persist even if the container is deleted.
```    
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins-latest
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        volumeMounts:
          - name: jenkins
            mountPath: /var/jenkins_home
      volumes:
        - name: jenkins
          persistentVolumeClaim:
            claimName: jenkins-pvc

"jenkins-deploy.yaml" 28L, 558C   
```
After you apply the yaml, you can check to see if your jenkins deployment container is up and running by entering the following command in your k3s host terminal: **"kubectl get pods"**.
```
k3-admin@k3-server:~/jenkins$ kubectl get pods
[sudo] password for k3-admin: 
NAME                                 READY   STATUS    RESTARTS   AGE
nginx-deployment-5d59d67564-jdt8t    1/1     Running   0          14d
nginx-deployment-5d59d67564-hkbnx    1/1     Running   0          14d
volume-test                          1/1     Running   0          10d
jenkins-deployment-c9dcd78f7-59dgl   1/1     Running   0          10d
```
#### Step 7: Deploy Your Jenkins Service:
From the directory where you saved your jenkins-service.yaml, you can apply your Jenkins service using the following command: **"kubectl apply -f jenkins-service.yaml"**. In your service yaml you are mapping your deployment jenkins app where the container is using port 8080 to node port 31080.  You mainly use node port type for Kubernetes services in a home lab environment. In a public cloud environment, you would use service type load balancer and your cloud provider would automaticially spin up a load balancer that you would connect from a client to access your Jenkins Web-UI.  For service type node port in this setup, you simmply use the ip address of your k3 host plus the node port port to access your Jenkins Web-UI, e.g., https://<k3 Kubernetes host IP address>:31080.  After setting up your password, you will be able to access your Jenkins Web-UI and start configuring your CI/CD pipeline services.  All your configurations will be pesistently stored on your local k3 host via your jenkins pvc.  To test that your persistent storage is working, delete your Jenkins service and deployment app by entering the following commands in your k3 terminal from the directory where your yaml's are stored: **"kubectl delete -f jenkins-service.yaml"** and **"kubectl delete -f jeninks-deploy.yaml"** then reapply these same yamls by entering the following commands: **"kubectl apply -f jenkins-deploy.yaml"** and **"jenkins-service.yaml"**. When you access your Jenkins Web-UI again using https:<k3 Kubernetes host IP address>:31080, you should be able to authenticate using the passwords you configured before deleting your jenkin service and deployment.
```apiVersion: v1
kind: Service
metadata:
  name: jenkins
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 31080
  selector:
    app: jenkins
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
~                                                                                                                 
"jenkins-service.yaml" 12L, 178C 
```   
## See the k3s terraform branch of this repository to deploy this same Jenkins service on a Rancher k3s kubernetes node using terraform. 
