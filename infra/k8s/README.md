# Kubernetes Local Setup (Single Public Port)

This setup exposes only one public endpoint locally:
- `http://kaarigar.local` (Ingress -> `api-gateway`)

All backend services stay internal in Kubernetes (`ClusterIP`).

## Prerequisites

- Minikube
- kubectl
- Docker

## 1) Start Minikube and enable Ingress

```powershell
minikube start
minikube addons enable ingress
```

## 2) Build all service images inside Minikube Docker

Use Minikube Docker daemon so Kubernetes can pull local images without registry push:

```powershell
minikube -p minikube docker-env --shell powershell | Invoke-Expression
./infra/k8s/build-images.ps1
```

## 3) Deploy manifests

```powershell
./infra/k8s/deploy-local.ps1
```

## 4) Route host to local ingress

Add this to your Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`):

```text
127.0.0.1 kaarigar.local
```

If needed, run a tunnel in another terminal:

```powershell
minikube tunnel
```

## 5) Verify

```powershell
kubectl get pods -n kaarigar
kubectl get ingress -n kaarigar
```

Then open:
- `http://kaarigar.local/health`
- `http://kaarigar.local/docs`

## Mobile app note

Your Flutter app currently defaults to `http://10.0.2.2`, so Android emulator traffic hits host port 80.  
If `kaarigar.local` is not resolved by emulator, pass an explicit base URL:

```powershell
flutter run --dart-define API_BASE_URL=http://10.0.2.2
```
