$ErrorActionPreference = "Stop"

$services = @(
  "api-gateway",
  "auth-service",
  "worker-service",
  "job-service",
  "geolocation-service",
  "review-rating-service",
  "payment-service",
  "notification-service"
)

foreach ($service in $services) {
  $dockerfile = "services/$service/Dockerfile"
  $tag = "kaarigar/$service`:local"
  Write-Host "Building $tag using $dockerfile"
  docker build -f $dockerfile -t $tag .
}

Write-Host "All service images built successfully."
