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
