#!/bin/sh

echo "-> Initializing Kubernetes cluster..."

minikube start --cpus 4 --memory 16g --driver docker --profile polar

echo "-> Enabling NGINX Ingress Controller..."

minikube addons enable ingress --profile polar

sleep 15

echo "-> Deploying Keycloak..."

kubectl apply -f services/keycloak-config.yml
kubectl apply -f services/keycloak.yml

sleep 5

echo "-> Waiting for Keycloak to be deployed..."

while [ $(kubectl get pod -l app=polar-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "-> Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=polar-keycloak \
  --timeout=300s

echo "-> Deploying PostgreSQL..."

kubectl apply -f services/postgresql.yml

sleep 5

echo "-> Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=polar-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "-> Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-postgres \
  --timeout=180s

echo "-> Deploying Redis..."

kubectl apply -f services/redis.yml

sleep 5

echo "-> Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=polar-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "-> Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-redis \
  --timeout=180s

echo "-> Deploying RabbitMQ..."

kubectl apply -f services/rabbitmq.yml

sleep 5

echo "-> Waiting for RabbitMQ to be deployed..."

while [ $(kubectl get pod -l db=polar-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "-> Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-rabbitmq \
  --timeout=180s

echo "-> Deploying Polar UI..."

kubectl apply -f services/polar-ui.yml

sleep 5

echo "-> Waiting for Polar UI to be deployed..."

while [ $(kubectl get pod -l app=polar-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "-> Waiting for Polar UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=polar-ui \
  --timeout=180s

echo "-> Happy Sailing!"