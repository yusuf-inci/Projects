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
2. Example: upgrade the cluster from 1.11 to 1.13
- Start with Master Node
- `kubeadm upgrade plan`, first upgrade kubeadm tools:  `apt-get upgrade -y kubeadm=1.12.0-00` then `kubeadm upgrade apply v1.12.0`, `kubectl get nodes`, If you run the kubectl get nodes command, you will still see the master node at 1.11. This is because in the output of this command, it is showing the versions of kubelets on each of these nodes registered with the API server and not the version of the API server itself. So the next step is to upgrade the kubelets.`apt-get upgrade -y kubelet=1.12.0-00`,`systemctl restart kubelet`. Running the kubectl get nodes command now shows that the master has been upgraded to 1.12. The worker nodes are still at 1.11.
- So next, the worker nodes. in this case use one at a time strategy.
- We need to first move the workloads from the first worker node to the other nodes. `kubectl drain node-1` The kubectl drain command lets you safely terminate all the pods from a node and reschedules them on the other nodes. it also cordons the node and marks it  unschedulable. That way, no new pods are scheduled on it. Then upgrade the kubeadm and kubelet packages on the worker nodes as we did on the master node. `apt-get upgrade -y kubeadm=1.12.0-00`, `apt-get upgrade -y kubelet=1.12.0-00`, `kubeadm upgrade node config --kubelet-version v1.12.0`, `systemctl restart kubelet`, The node should now be up with the new software version. However, when we drain the node, we actually marked it unschedulable,
so we need to unmark it by running the command `kubectl uncordon node-1` The node is now schedulable. But remember that it is not necessary that the pods come right back to this node. It is only marked as schedulable. Only when the pods are deleted from the other nodes
or when new pods are scheduled do they really come back to this first node. Well, it will soon come when we take down the second node to perform the same steps to upgrade it, and finally, the third node. We now have all nodes upgraded.
