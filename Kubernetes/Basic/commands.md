# Commands
## Minikube
- Start a cluster using the virtualbox driver: `minikube start --driver=virtualbox`
- stop minikube: - `minikube stop`, `minikube status` 
- Start a cluster using the docker driver: `minikube start --driver=docker`
- `kubectl get po -A`, `minikube kubectl -- get po -A`, `alias kubectl="minikube kubectl --"`, `minikube dashboard`, 
- Create a sample deployment and expose it on port 8080: `kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0`, `kubectl expose deployment hello-minikube --type=NodePort --port=8080`, `kubectl get services hello-minikube`, `minikube service hello-minikube`, `minikube service hello-minikube --url` or `kubectl port-forward service/hello-minikube 7080:8080`, `http://localhost:7080/`
- Create an NGINX Pod: `kubectl run nginx --image=nginx`, `kubectl get pod`, `kubectl describe pod nginx`, `kubectl get pods -o wide`,
- To create a deployment using imperative command, use kubectl create: `kubectl create deployment nginx --image=nginx`, 
- `kubectl run nginx --image=nginx`, `kubectl get pods -o wide`, 
`kubectl run redis --image=redis123 --dry-run=client -o yaml > redis-definition.yaml`, `kubectl edit pod redis`, 
## ReplicaSet
- Create ReplicaSet: `kubectl create -f replicaset-definition.yml`, `kubectl get replicaset`, `kubectl get pods`,
- Scale / Update ReplicaSet:
1. update definition file then run `kubectl replace -f replicaset-definition.yml`
2. edit kubernetes live definition file but definition file will not be updated. this will effect directly live system. run `kubectl edit replicaset myapp-replicaset` this will open the file and update number of replica you want save and exit.
3. using command but definition file will not be updated. `kubectl scale --replicas=5 -f replicaset-definition.yml` or `kubectl scale replicaset myapp-replicaset --replicas=4 `
- Delete ReplicaSet: `kubectl get replicaset`, `kubectl delete replicaset myapp-replicaset` or `kubectl delete -f <file-name>.yaml`
- You can check for apiVersion of replicaset by command `kubectl api-resources | grep replicaset`
- `kubectl explain replicaset`

## Deployments
- get all object: `kubectl get all`
- create deployment: `kubectl create -f deployment.yaml`, 
- List deployment: `kubectl get deployments`
- update deployment: `kubectl apply -f deployment.yaml`. to record the cause of change: `kubectl apply -f deployment.yaml --record`
- undo deployment: `kubectl rollout undo deployment/myapp-deployment`
- `kubectl describe deployment myapp-deployment`
- get help: `kubectl create deploy --help`
### Update & Rollback
- To see revision and history of rollout: `kubectl rollout status deployment/myapp-deployment` ,`kubectl rollout history deployment/myapp-deployment`
- Deployment Strategy: 
1. Recreate Strategy: destroy all and recreate all. App down during process
2. Rolling Update: destroy and recreate one by one. App never down during process. Default strategy.
- update image in definition file and run apply command or run kubectl set image command `kubectl set image deployment/myapp-deployment \ nginx-container=nginx:1.9.1` (deployment definition file will not change)

## Service
- create Service: `kubectl create -f service-definition.yaml`
- `kubectl get svc`
- to print service url: `minikube service myapp-service --url`

## Certification Tip!
- Using the `kubectl run` command can help in generating a YAML template. And sometimes, you can even get away with just the `kubectl run` command without having to create a YAML file at all. For example, if you were asked to create a pod or deployment with specific name and image you can simply run the kubectl run command.
- Reference (Bookmark this page for exam. It will be very handy): `https://kubernetes.io/docs/reference/kubectl/conventions/`
- Create an NGINX Pod: `kubectl run nginx --image=nginx`
- Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run): `kubectl run nginx --image=nginx --dry-run=client -o yaml`
- Create a deployment: `kubectl create deployment --image=nginx nginx`
- Generate Deployment YAML file (-o yaml). Don't create it(--dry-run): `kubectl create deployment --image=nginx nginx --dry-run=client -o yaml`
- Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file. `kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml`
- Make necessary changes to the file (for example, adding more replicas) and then create the deployment. `kubectl create -f nginx-deployment.yaml` OR In k8s version 1.19+, we can specify the --replicas option to create a deployment with 4 replicas. `kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml`

## Namespace
- `kubectl create namespace dev`
- `kubectl create -f namespace-dev.yaml`
- `kubectl get pods --namespace=dev`
- to work directly in dev namespace then run `kubectl config set-context $(kubectl config current-context) --namespace=dev`
- to get all pods in all namespaces run `kubectl get pods --all-namespaces`
- `kubectl run redis --image=redis -n dev`
- `kubectl config view --minify | grep namespace`

## Certification Tips - Imperative Commands with Kubectl  
While you would be working mostly the declarative way - using definition files, imperative commands can help in getting one time tasks done quickly, as well as generate a definition template easily. This would help save considerable amount of time during your exams.  

Before we begin, familiarize with the two options that can come in handy while working with the below commands:  

`--dry-run`: By default as soon as the command is run, the resource will be created. If you simply want to test your command , use the `--dry-run=client` option. This will not create the resource, instead, tell you whether the resource can be created and if your command is right.  

`-o yaml`: This will output the resource definition in YAML format on screen.  



Use the above two in combination to generate a resource definition file quickly, that you can then modify and create resources as required, instead of creating the files from scratch.  

- POD  
Create an NGINX Pod  

`kubectl run nginx --image=nginx`  

Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)

`kubectl run nginx --image=nginx --dry-run=client -o yaml`  

- Deployment  
Create a deployment  

`kubectl create deployment --image=nginx nginx`  

Generate Deployment YAML file (-o yaml). Don't create it(--dry-run)  

`kubectl create deployment --image=nginx nginx --dry-run=client -o yaml`  

Generate Deployment with 4 Replicas  

`kubectl create deployment nginx --image=nginx --replicas=4`  

You can also scale a deployment using the kubectl scale command.  

`kubectl scale deployment nginx --replicas=4`  

Another way to do this is to save the YAML definition to a file and modify

`kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml`  

You can then update the YAML file with the replicas or any other field before creating the deployment.  


- Service    
Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379  

`kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml`  

(This will automatically use the pod's labels as selectors)  

Or  

`kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml` (This will not use the pods labels as selectors, instead it will assume selectors as app=redis. You cannot pass in selectors as an option. So it does not work very well if your pod has a different label set. So generate the file and modify the selectors before creating the service)  

Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes:  

`kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml`  

(This will automatically use the pod's labels as selectors, but you cannot specify the node port. You have to generate a definition file and then add the node port in manually before creating the service with the pod.)  

Or  

`kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml`  

(This will not use the pods labels as selectors)  

Both the above commands have their own challenges. While one of it cannot accept a selector the other cannot accept a node port. I would recommend going with the kubectl expose command. If you need to specify a node port, generate a definition file using the same command and manually input the nodeport before creating the service.

- Lab  
`kubectl run nginx-pod --image=nginx:alpine`,  
`kubectl run redis --image=redis:alpine --labels tier=db --dry-run=client -o yaml > redis.yaml`,  
`kubectl expose pod redis --port=6379 --name redis-service`,  
`kubectl expose pod redis --port=6379 --name=redis-service --dry-run=client -o yaml > redis-service.yaml`,  
`kubectl create deployment webapp --image=kodekloud/webapp-color --replicas=3`,  
`kubectl run custom-nginx --image=nginx --port=8080`,
`kubectl create namespace dev-ns`,  
`kubectl create deployment redis-deploy --image=redis --replicas=2 -n dev-ns`,  
`kubectl run httpd --image=httpd:alpine --port=80 --expose`,  


## Scheduling
### Manuel Scheduling
- add nodeName to spec --> containers --> nodeName
- if you use create command and want to recreate then run `kubectl replace --force -f manuel-scheduling.yaml` it will delete and create  
- if you want to monitor the status the run `kubectl get pods --watch` if any update occer then it shows  
### Labels & Selector  
- `kubectl get pod --selector env=dev`  
- `kubectl get all --selector env=prod` , `kubectl get all --selector env=prod --no-headers | wc -l`
- `kubectl get all --selector env=prod,bu=finance,tier=frontend`  
### Taints And Tolerations
- `kubectl taint nodes node-name key=value:taint-effect`, taint effects: NoSchedule | PreferNoSchedule | NoExecute, `kubectl taint nodes node1 app=myapp:NoSchedule`
- get taints on node01: `kubectl describe node node01 | grep -i taints`  
- Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule: `kubectl taint nodes node01 spray=mortein:NoSchedule`, 
- Remove the taint on controlplane, which currently has the taint effect of NoSchedule: `kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-`  
### Node Affinity LAB
- add label to a node: `kubectl label node node01 color=red`
- to check the taints on nodes: `kubectl describe node node01 | grep -i taints`
- `kubectl create deployment red --image=nginx --replicas=2 --dry-run=client -o yaml > red.yaml`
### Resource Limits
- to get the output every two seconds: `watch kubectl get pods`, `watch kubectl describe pod elephant`
### DeamonSet  
- `kubectl get daemonsets`
- `kubectl get daemonsets --all-namespaces` or `kubectl get daemonsets -A`
- `kubectl describe daemonsets monitoring-daemon`
- An easy way to create a DaemonSet is to first generate a YAML file for a Deployment with the command `kubectl create deployment elasticsearch --image=registry.k8s.io/fluentd-elasticsearch:1.20 -n kube-system --dry-run=client -o yaml > fluentd.yaml` Next, remove the replicas, strategy and status fields from the YAML file using a text editor. Also, change the kind from Deployment to DaemonSet. Finally, create the Daemonset by running `kubectl create -f fluentd.yaml`  
### Static PODs
- to figure out static pods exist in the cluster in all namespaces, Run the command `kubectl get pods --all-namespaces` and look for those with -controlplane appended in the name  
- Create a static pod named static-busybox that uses the busybox image and the command sleep 1000 ==> Create a pod definition file in the manifests folder. To do this, run the command: `kubectl run --restart=Never --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml`  
### MULTIPLE SCHEDULERS  
- Deploy Additional Scheduler - kubeadm: ref: `/etc/kubernetes/manifests/kube-scheduler.yaml` and `my-custom-scheduler.yaml`,
- View Schedulers: `kubectl get pods --namespace=kube-system`
- Inspect the kubernetes scheduler pod and identify the image: `kubectl describe pod kube-scheduler-controlplane --namespace=kube-system`
- Use Custom Scheduler: `kubectl get pods --namespace=kube-system`
- View Events: `kubectl get events`
- View Scheduler Logs: `kubectl logs my-custom-scheduler --name-space=kube-system`
- Deploy Additional Scheduler - kubeadm: ref:`/etc/kubernetes/manifests/kube-scheduler.yaml` and `my-custom-scheduler.yaml`

## Application Lifecycle Management
### Rolling Updates and Rollbacks
- Create: `kubectl create –f deployment-definition.yml`
- Get: `kubectl get deployments`
- Update: `kubectl apply –f deployment-definition.yml` or `kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1`
- Status: `kubectl rollout status deployment/myapp-deployment` or `kubectl rollout history deployment/myapp-deployment`
- Rollback: `kubectl rollout undo deployment/myapp-deployment`
### Application Commands
- `kubectl create –f pod-definition.yml`,  `ENTRYPOINT [“sleep”]` ==> `command:[“sleep2.0”]`, `CMD [“5”]` ==> `args:[“10”]`
### Environment Variables
1. app.py (color = os.environ.get('APP_COLOR')) ==> `export APP_COLOR=blue; python app.py`
2.  ENV Variables in Docker: `docker run simple-webapp-color`, `docker run -e APP_COLOR=blue
simple-webapp-color`, 
3. ENV Variables in Kubernetes:  
- `docker run -e APP_COLOR=pink simple-webapp-color` 
- env-var-pod-definition.yaml
- Plain Key Value:  
env:
    - name: APP_COLOR
      value: pink   
- ConfigMap
env:
    - name: APP_COLOR
      valueFrom:
        configMapKeyRef: 
- Secrets  
env:
    - name: APP_COLOR
      valueFrom:
        secretKeyRef:
### ConfigMaps
- Imperative: `kubectl create configmap <config-name> --from-literal=<key>=<value>`, `kubectl create configmap \
app-config --from-literal=APP_COLOR=blue \
--from-literal=APP_MOD=prod`, `kubectl create configmap <config-name> --from-file=<path-to-file>`, `kubectl create configmap \
app-config --from-file=app_config.properties`, 
- Declarative: `kubectl create –f config-map.yaml`, `kubectl get configmaps`, `kubectl create –f ConfigMapinPods.yaml`
### Secrets
- Imperative: 
1. `kubectl create secret generic <secret-name> --from-literal=<key>=<value>`, `kubectl create secret generic app-secret --from-literal=DB_Host=mysql --from-literal=DB_User=root --from-literal=DB_Password=paswrd` , 
2. `kubectl create secret generic <secret-name> --from-file=<path-to-file>`, `kubectl create secret generic app-secret --from-file=app_secret.properties`  
- Declarative: `kubectl create –f secret-data.yaml`  
Encode Secrets ==> `echo –n ‘mysql’ | base64`  
View Secrets: `kubectl get secrets`, `kubectl describe secrets`, `kubectl get secret app-secret –o yaml`  
Decode Secrets: `echo –n ‘bXlzcWw=’ | base64 --decode`

### Multi-Container PODs  
You may need two services to work together, such as a web server and a logging service. You need one agent instance per web server instance paired together. You only need the two functionality to work together. You need one agent per web server instance paired together that can scale up and down together and that is why you have multi container pods that share the same life cycle, which means they are created together and destroyed together. They share the same network space, which means they can refer to each other as local host, and they have access to the same storage volumes. This way you do not have to establish volume sharing or services between the pods to enable communication between them. To create a multi-container pod, add the new container information to the pod definition file.
- `kubectl run yellow --image=busybox --dry-run=client -o yaml > multicontainer-yellow.yaml`, `kubectl apply -f multicontainer-yellow.yaml`, 
- `kubectl -n elastic-stack exec -it app -- cat /log/app.log` or
- `kubectl -n elastic-stack logs app`

###  initContainers  
- An initContainer is configured in a pod like all other containers, except that it is specified inside a initContainers section. A process that pulls a code or binary from a repository that will be used by the main web application. That is a task that will be run only  one time when the pod is first created. Or a process that waits  for an external service or database to be up before the actual application starts. When a POD is first created the initContainer is run, and the process in the initContainer must run to a completion before the real container hosting the application starts. You can configure multiple such initContainers as well. In that case each init container is run one at a time in sequential order.
- `kubectl describe pod orange`, `kubectl logs orange`, `kubectl logs orange -c <container name>`,`kubectl logs orange -c init-myservice`

## Cluster Maintanance
### Operating System Upgrade
- If the node came back online immediately after it is down, the kubelet process starts and the pods come back online. However, if the node was down for more than five minutes, the pods are terminated from that node. If the pods were part of your replica set, then they are recreated on other nodes. The time it waits for a pod to come back online is known as the pod-eviction-timeout and is set on the controller manager with a default value of five minutes. So whenever a node goes offline, the master node waits for up to five minutes before considering the node dead.When the node comes back online after the  pod-eviction-timeout, it comes up blank without any pod scheduled on it.
- `kubectl drain node-1` ==> the workloads are moved to other nodes in the cluster. In fact When you drain a node, the pods are gracefully terminated from the node that they're on and recreated on another.The node is also cordoned or marked as unschedulable.
- `kubectl uncordon node-1` ==> When it comes back online, it is still unschedulable. You then need to uncordon it so that the pods can be scheduled on it again. But the pods that were moved to the other nodes don't automatically fall back. If any of those pods were deleted or if new pods were created in the cluster, then they would be created on this node.
- `kubectl cordon node-2` ==> Apart from drain and uncordon, there is also another command called cordon. Cordon simply marks a node unschedulable. Unlike drain, it does not terminate or move the pods on an existing node. It simply makes sure that new pods are not scheduled on that node.
- Lab commands: `kubectl get nodes`, `kubectl get deployments`, `kubectl get pods -o wide`, `kubectl drain node01 --ignore-daemonsets`, `kubectl uncordon node01`, `kubectl drain node01 --ignore-daemonsets --force`, `kubectl cordon node01`

### Cluster Upgrade Process
1. Info
- The components can be at different release versions. Since the kube-apiserver is the primary component in the control plane, and that is the component that all other components talk to, none of the other components should ever be at a version higher than the kube-apiserver. The controller-manager and scheduler can be at one version lower. Except for others The kubectl utility could be at a version higher than the API server or the same version as the API server or a version lower than the API server.
- You should upgrade one minor version one. (v.1.10 >> v.1.11). You should upgrade before three version release So with 1.12 being the latest release, Kubernetes supports versions 1.12, 1.11, and 1.10. So when 1.13 is released, only versions 1.13, 1.12, and 1.11 are supported. Before the release of 1.13 would be a good time to upgrade your cluster to the next release. The recommended approach is to upgrade one minor version at a time, version 1.10 to 1.11, then 1.11 to 1.12, and then 1.12 to 1.13.
- Upgrading a cluster involves two major steps. First, you upgrade your master nodes and then upgrade the worker nodes. While the master is being upgraded, the control plane components, such as the API server, scheduler, and controller-managers, go down briefly. The master going down does not mean your worker nodes and applications on the cluster are impacted. All workloads hosted on the worker nodes continue to serve users as normal. Since the master is down, all management functions are down. You cannot access the cluster using kubectl or other Kubernetes API. You cannot deploy new applications or delete or modify existing ones. The controller-managers don't function either. If a pod was to fail, a new pod won't be automatically created. But as long as the nodes and the pods are up, your applications should be up, and users will not be impacted. Once the upgrade is complete and the cluster is back up, it should function normally.
2. Example 1: upgrade the cluster from 1.11 to 1.13
- Start with Master Node
- `kubeadm upgrade plan`, first upgrade kubeadm tools:  `apt-get upgrade -y kubeadm=1.12.0-00` then `kubeadm upgrade apply v1.12.0`, `kubectl get nodes`, If you run the kubectl get nodes command, you will still see the master node at 1.11. This is because in the output of this command, it is showing the versions of kubelets on each of these nodes registered with the API server and not the version of the API server itself. So the next step is to upgrade the kubelets.`apt-get upgrade -y kubelet=1.12.0-00`,`systemctl restart kubelet`. Running the kubectl get nodes command now shows that the master has been upgraded to 1.12. The worker nodes are still at 1.11.
- So next, the worker nodes. in this case use one at a time strategy.
- We need to first move the workloads from the first worker node to the other nodes. `kubectl drain node-1` The kubectl drain command lets you safely terminate all the pods from a node and reschedules them on the other nodes. it also cordons the node and marks it  unschedulable. That way, no new pods are scheduled on it. Then upgrade the kubeadm and kubelet packages on the worker nodes as we did on the master node. `apt-get upgrade -y kubeadm=1.12.0-00`, `apt-get upgrade -y kubelet=1.12.0-00`, `kubeadm upgrade node config --kubelet-version v1.12.0`, `systemctl restart kubelet`, The node should now be up with the new software version. However, when we drain the node, we actually marked it unschedulable,
so we need to unmark it by running the command `kubectl uncordon node-1` The node is now schedulable. But remember that it is not necessary that the pods come right back to this node. It is only marked as schedulable. Only when the pods are deleted from the other nodes
or when new pods are scheduled do they really come back to this first node. Well, it will soon come when we take down the second node to perform the same steps to upgrade it, and finally, the third node. We now have all nodes upgraded.
3. Example: 2
- `kubectl get nodes`
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   34m   v1.28.0
node01         Ready    <none>          33m   v1.28.0
- controlplane ~ ➜  `kubectl describe nodes controlplane | grep -i taints`
Taints:             <none>
- controlplane ~ ✖ `kubectl describe nodes node01 | grep -i taint`
Taints:             <none>
-  `kubectl get deploy`
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
blue   5/5     5            5           6m37s
- controlplane ~ ➜  `kubectl get pods -o wide`
NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
blue-667bf6b9f9-69r65   1/1     Running   0          7m22s   10.244.1.4   node01         <none>           <none>
blue-667bf6b9f9-7jd97   1/1     Running   0          7m22s   10.244.0.4   controlplane   <none>           <none>
blue-667bf6b9f9-7s495   1/1     Running   0          7m22s   10.244.1.2   node01         <none>           <none>
blue-667bf6b9f9-8j86l   1/1     Running   0          7m22s   10.244.0.5   controlplane   <none>           <none>
blue-667bf6b9f9-z9t7j   1/1     Running   0          7m22s   10.244.1.3   node01         <none>           <none>
- `kubeadm upgrade plan`
- `kubectl drain controlplane --ignore-daemonsets`
- controlplane ~ ➜  `kubectl get pods -o wide`
NAME                    READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
blue-667bf6b9f9-4p6nq   1/1     Running   0          22s   10.244.1.8   node01   <none>           <none>
blue-667bf6b9f9-69r65   1/1     Running   0          11m   10.244.1.4   node01   <none>           <none>
blue-667bf6b9f9-7s495   1/1     Running   0          11m   10.244.1.2   node01   <none>           <none>
blue-667bf6b9f9-jpg54   1/1     Running   0          21s   10.244.1.9   node01   <none>           <none>
blue-667bf6b9f9-z9t7j   1/1     Running   0          11m   10.244.1.3   node01   <none>           <none>
- Use any text editor you prefer to open the file that defines the Kubernetes apt repository. `vim /etc/apt/sources.list.d/kubernetes.list`
Update the version in the URL to the next available minor release, i.e v1.29.
`deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /`.  After making changes, save the file and exit from your text editor. `apt update`, `apt-cache madison kubeadm`, Based on the version information displayed by apt-cache madison, it indicates that for Kubernetes version 1.29.0, the available package version is 1.29.0-1.1. Therefore, to install kubeadm for Kubernetes v1.29.0, use the following command:  `apt-get install kubeadm=1.29.0-1.1` 
Run the following command to upgrade the Kubernetes cluster. `kubeadm upgrade plan v1.29.0`, `kubeadm upgrade apply v1.29.0`. Now, upgrade the version and restart Kubelet. Also, mark the node (in this case, the "controlplane" node) as schedulable.
root@controlplane:~# `apt-get install kubelet=1.29.0-1.1`
root@controlplane:~# `systemctl daemon-reload`
root@controlplane:~# `systemctl restart kubelet`
root@controlplane:~# `kubectl uncordon controlplane`
- controlplane ~ ➜  `kubectl drain node01 --ignore-daemonsets`
- On the node01 node, run the following commands: Use any text editor you prefer to open the file that defines the Kubernetes apt repository.  `vim /etc/apt/sources.list.d/kubernetes.list` Update the version in the URL to the next available minor release, i.e v1.29. `deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /` After making changes, save the file and exit from your text editor. Proceed with the next instruction.
root@node01:~# `apt update`
root@node01:~# `apt-cache madison kubeadm`
Based on the version information displayed by apt-cache madison, it indicates that for Kubernetes version 1.29.0, the available package version is 1.29.0-1.1. Therefore, to install kubeadm for Kubernetes v1.29.0, use the following command:
root@node01:~# `apt-get install kubeadm=1.29.0-1.1`
Upgrade the node : root@node01:~# `kubeadm upgrade node`
Now, upgrade the version and restart Kubelet.
root@node01:~# `apt-get install kubelet=1.29.0-1.1`
root@node01:~# `systemctl daemon-reload`
root@node01:~# `systemctl restart kubelet`
- controlplane ~ ➜  `kubectl uncordon node01`

## Backup and Restore
### Resource Configuration
- Source code Management, github etc.
- kube-apiserver: `kubectl get all --all-namespaces -o yaml > all-deploy-services.yaml`
### ETCD Cluster
#### Back up and restore Stacked ETCD
- to view all cluster: `kubectl config view`
- to get the version of ETCD running on the cluster: `kubectl get pods -n kube-system`,`kubectl describe pod etcd-controlplane -n kube-system` then find the container image, or `kubectl -n kube-system logs etcd-controlplane | grep -i 'etcd-version'` or `kubectl -n kube-system describe pod etcd-controlplane | grep Image:`
- to reach the ETCD cluster from the controlplane node: `kubectl -n kube-system describe pod etcd-controlplane | grep '\--listen-client-urls'`
-  ETCD server certificate file located at `kubectl describe pod etcd-controlplane  -n kube-system` and look for the value for --cert-file or `kubectl -n kube-system describe pod etcd-controlplane | grep '\--cert-file'`
-  ETCD CA Certificate file located at `kubectl -n kube-system describe pod etcd-controlplane | grep '\--trusted-ca-file'`
- etcd is a static pod so definition file is at `vim /etc/kubernetes/manifests/etcd.yaml` examine this file
- to take backup:   
`ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db` or
- `export ETCDCTL_API=3`, `etcdctl snapshot save --endpoints=127.0.0.1:2379 \
> --cacert=/etc/kubernetes/pki/etcd/ca.crt\
> --cert=/etc/kubernetes/pki/etcd/server.crt \
> --key=/etc/kubernetes/pki/etcd/server.key \
> /opt/snapshot-pre-boot1.db`
- to restore:
First Restore the snapshot:

root@controlplane:~# `ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup \
snapshot restore /opt/snapshot-pre-boot.db`


2022-03-25 09:19:27.175043 I | mvcc: restore compact to 2552
2022-03-25 09:19:27.266709 I | etcdserver/membership: added member 8e9e05c52164694d [http://localhost:2380] to cluster cdf818194e3a8c32
root@controlplane:~# 


Note: In this case, we are restoring the snapshot to a different directory but in the same server where we took the backup (the controlplane node) As a result, the only required option for the restore command is the --data-dir.


Next, update the /etc/kubernetes/manifests/etcd.yaml:

We have now restored the etcd snapshot to a new path on the controlplane - /var/lib/etcd-from-backup, so, the only change to be made in the YAML file, is to change the hostPath for the volume called etcd-data from old directory (/var/lib/etcd) to the new directory `/var/lib/etcd-from-backup`.

  volumes:
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data
With this change, /var/lib/etcd on the container points to /var/lib/etcd-from-backup on the controlplane (which is what we want).

When this file is updated, the ETCD pod is automatically re-created as this is a static pod placed under the /etc/kubernetes/manifests directory.



Note 1: As the ETCD pod has changed it will automatically restart, and also kube-controller-manager and kube-scheduler. Wait 1-2 to mins for this pods to restart. You can run the command: `watch "crictl ps | grep etcd"` to see when the ETCD pod is restarted.

Note 2: If the etcd pod is not getting Ready 1/1, you can check `kubectl describe pod etcd-controlplane -n kube-system` if you see any error or  then restart it by `kubectl delete pod -n kube-system etcd-controlplane` and wait 1 minute.

Note 3: This is the simplest way to make sure that ETCD uses the restored data after the ETCD pod is recreated. You don't have to change anything else.



If you do change --data-dir to /var/lib/etcd-from-backup in the ETCD YAML file, make sure that the volumeMounts for etcd-data is updated as well, with the mountPath pointing to /var/lib/etcd-from-backup (THIS COMPLETE STEP IS OPTIONAL AND NEED NOT BE DONE FOR COMPLETING THE RESTORE)
#### Restore External ETCD
- An ETCD backup for cluster2 is stored at /opt/cluster2.db. Use this snapshot file to carryout a restore on cluster2 to a new path /var/lib/etcd-data-new.
`student-node ~ ➜  kubectl config use-context cluster2`, Copy the snapshot file from the student-node to the etcd-server. student-node ~  `scp /opt/cluster2.db etcd-server:/root`. Restore the snapshot on the cluster2. Since we are restoring directly on the etcd-server, we can use the endpoint https:/127.0.0.1. Use the same certificates that were identified earlier. Make sure to use the data-dir as /var/lib/etcd-data-new: etcd-server ~ ➜  `ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/pki/ca.pem --cert=/etc/etcd/pki/etcd.pem --key=/etc/etcd/pki/etcd-key.pem snapshot restore /root/cluster2.db --data-dir /var/lib/etcd-data-new`. Update the systemd service unit file for etcdby running vi /etc/systemd/system/etcd.service and add the new value for data-dir:
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
User=etcd
Type=notify
ExecStart=/usr/local/bin/etcd \
  --name etcd-server \
  --data-dir=/var/lib/etcd-data-new \  make sure the permissions on the new directory is correct (should be owned by etcd user): etcd-server /var/lib ➜  `chown -R etcd:etcd /var/lib/etcd-data-new`
 Once the restore is complete, ensure that the controlplane components on cluster2 are running. Finally, reload and restart the etcd service.
etcd-server ~/default.etcd ➜  `systemctl daemon-reload`
etcd-server ~ ➜  `systemctl restart etcd`
It is recommended to restart controlplane components (e.g. kube-scheduler, kube-controller-manager, kubelet) to ensure that they don't rely on some stale data.
`kubectl delete pods kube-controller-manager-cluster2-controlplane kube-scheduler-cluster2-controlplane -n kube-system`, ssh to conrol plane `ssh cluster2-controlplane`, restart kubelet `systemctl restart kubelet`



### Persistent Volumes

## SECURITY

### Secure Hosts: 
- Password based authentication disabled,  
- SSH Key based authentication

### Secure Kubernetes:
1. Authentication: (Who can access?)
- Files – Username and Passwords
- Files – Username and Tokens
- Certificates
- External Authentication providers - LDAP
- Service Accounts
2. Authorization (What can they do?)
- RBAC Authorization
- ABAC Authorization
- Node Authorization
- Webhook Mode 

### TLS CERTIFICATES
1. Server Certificates for Servers
- KUBE-API SERVER: apiserver.crt --- apiserver.key 
- ETCD SERVER: etcdserver.crt --- etcdserver.key
- KUBELET SERVER: kubelet.crt --- kubelet.key
2. Client Certificates for Clients
- KUBE-API SERVER: 
- ETCD SERVER: apiserver-etcd-client.crt --- apiserver-etcd-client.key
- KUBELET SERVER: kubelet-client.crt --- kubelet-client.key
- admin: admin.crt --- admin.key
- KUBE-SCHEDULER: scheduler.crt --- scheduler.key
- KUBE-CONTROLLER-MANAGER: controller-manager.crt --- controller-manager.key
- KUBE-PROXY: kube-proxy.crt --- kube-proxy.key