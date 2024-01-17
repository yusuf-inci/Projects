
`minikube start`
`docker ps`
`kubectl get nodes`
`cat ~/.kube/config`

`minikube dashboard`
`kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.39 -- /agnhost netexec --http-port=8080`
`kubectl get deployments`
`kubectl get pods`
`kubectl get events`
`kubectl config view`
`kubectl get pods`
`kubectl logs hello-node-ccf4b9788-lf7ml`
`kubectl expose deployment hello-node --type=LoadBalancer --port=8080`
`kubectl get services`
`minikube service hello-node`
`minikube addons list`
`minikube addons enable metrics-server`
`kubectl get pod,svc -n kube-system`
`kubectl top pods`
`minikube addons disable metrics-server`
`kubectl delete service hello-node`
`kubectl delete deployment hello-node`

# ------

`kubectl get po -A`
`minikube kubectl -- get po -A`
`alias kubectl="minikube kubectl --"`
`kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0`
`kubectl expose deployment hello-minikube --type=NodePort --port=8080`
`kubectl get services hello-minikube`
`minikube service hello-minikube`
`minikube service hello-minikube --url`
`kubectl port-forward service/hello-minikube 7080:8080`
``
# ----------
`echo "vprodbpass" | base64`
`echo "guest" | base64`
# -------
`kubectl apply -f .`
`kubectl get service vproapp-service`
`minikube ip`
`minikube service vproapp-service --url`
`http://192.168.49.2:32231`
`kubectl delete -f .`
