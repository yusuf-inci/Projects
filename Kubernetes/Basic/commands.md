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

## Deployments
- get all object: `kubectl get all`
- create deployment: `kubectl create -f deployment.yaml`, 
- List deployment: `kubectl get deployments`
- update deployment: `kubectl apply -f deployment.yaml`
- undo deployment: `kubectl rollout undo deployment/myapp-deployment`
- `kubectl describe deployment myapp-deployment`
- get help: `kubectl create deploy --help`
### Update & Rollback
- To see revision and history of rollout: `kubectl rollout status deployment/myapp-deployment` ,`kubectl rollout history deployment/myapp-deployment`
- Deployment Strategy: 
1. Recreate Strategy: destroy all and recreate all. App down during process
2. Rolling Update: destroy and recreate one by one. App never down during process. Default strategy.
- update image in definition file and run apply command or run kubectl set image command `kubectl set image deployment/myapp-deployment \ nginx-container=nginx:1.9.1` (deployment definition file will not change)