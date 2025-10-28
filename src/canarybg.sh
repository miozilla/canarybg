#!/bin/bash

gcloud config set compute/zone ZONE

gcloud storage cp -r gs://spls/gsp053/kubernetes .
cd kubernetes

gcloud container clusters create bootcamp \
  --machine-type e2-small \
  --num-nodes 3 \
  --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"
  
kubectl explain deployment

# kubectl explain deployment --recursive

kubectl explain deployment.metadata.name

# Create deployment
cat deployments/fortune-app-blue.yaml

kubectl create -f deployments/fortune-app-blue.yaml

kubectl get deployments

kubectl get replicasets

kubectl get pods

kubectl create -f services/fortune-app.yaml

curl http://<EXTERNAL-IP>/version

curl http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version

# Scale deployment
kubectl scale deployment fortune-app-blue --replicas=5

kubectl get pods | grep fortune-app-blue | wc -l

kubectl scale deployment fortune-app-blue --replicas=3

kubectl get pods | grep fortune-app-blue | wc -l

# Rolling update
# kubectl edit deployment fortune-app-blue
# image: "us-central1-docker.pkg.dev/qwiklabs-resources/spl-lab-apps/fortune-service:2.0.0"
# value: "2.0.0"

kubectl get replicaset

kubectl rollout history deployment/fortune-app-blue

# Pause rolling update
kubectl rollout pause deployment/fortune-app-blue

kubectl rollout status deployment/fortune-app-blue

for p in $(kubectl get pods -l app=fortune-app -o=jsonpath='{.items[*].metadata.name}'); do echo $p && curl -s http://$(kubectl get pod $p -o=jsonpath='{.status.podIP}')/version; echo; done

kubectl rollout resume deployment/fortune-app-blue

kubectl rollout status deployment/fortune-app-blue

kubectl rollout undo deployment/fortune-app-blue

curl http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version

# Canary deployments
cat deployments/fortune-app-canary.yaml

kubectl create -f deployments/fortune-app-canary.yaml

kubectl get deployments

for i in {1..10}; do curl -s http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version; echo;
done

# Blue-green deployments
kubectl apply -f services/fortune-app-blue-service.yaml

kubectl create -f deployments/fortune-app-green.yaml

curl http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version

kubectl apply -f services/fortune-app-green-service.yaml

curl http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version

kubectl apply -f services/fortune-app-blue-service.yaml

curl http://`kubectl get svc fortune-app -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version







