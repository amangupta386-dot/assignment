$ErrorActionPreference = "Stop"

kubectl apply -f infra/k8s/namespace.yaml
kubectl apply -f infra/k8s/configmap.yaml
kubectl apply -f infra/k8s/dependencies.yaml
kubectl apply -f infra/k8s/services.yaml
kubectl apply -f infra/k8s/gateway.yaml

kubectl -n kaarigar rollout status deploy/postgres --timeout=180s
kubectl -n kaarigar rollout status deploy/redis --timeout=180s
kubectl -n kaarigar rollout status deploy/kafka --timeout=180s
kubectl -n kaarigar rollout status deploy/auth-service --timeout=180s
kubectl -n kaarigar rollout status deploy/worker-service --timeout=180s
kubectl -n kaarigar rollout status deploy/job-service --timeout=180s
kubectl -n kaarigar rollout status deploy/geolocation-service --timeout=180s
kubectl -n kaarigar rollout status deploy/review-rating-service --timeout=180s
kubectl -n kaarigar rollout status deploy/payment-service --timeout=180s
kubectl -n kaarigar rollout status deploy/notification-service --timeout=180s
kubectl -n kaarigar rollout status deploy/api-gateway --timeout=180s

Write-Host "Deployment complete."
Write-Host "If using Minikube, run: minikube addons enable ingress"
Write-Host "Then map the host: 127.0.0.1 kaarigar.local"
