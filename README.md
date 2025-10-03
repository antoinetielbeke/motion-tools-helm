# Motion Tools Helm Chart

A Helm chart for deploying [Motion Tools (Antragsgrün)](https://github.com/CatoTH/antragsgruen) on Kubernetes. Motion Tools is an online platform for NGOs, political parties, and social initiatives to collaboratively discuss resolutions, party platforms, and amendments.

## Features

- **Easy Deployment**: Simple installation with sensible defaults
- **Database Management**: Integrated MariaDB or external database support
- **Persistent Storage**: Data persistence across pod restarts
- **Security**: Built-in security configurations and network policies
- **Monitoring**: Health checks and probes configured
- **Customizable**: Extensive configuration options for all components

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- Optional: cert-manager for automatic TLS certificate management

## Installation

### Add the Helm repository

```bash
# Add the Motion Tools repository hosted on Cloudsmith
helm repo add motion-tools https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/
helm repo update
```

### Install with default configuration

```bash
# From repository
helm install motion-tools motion-tools/motion-tools

# Direct install without adding repository
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/' \
  motion-tools
```

### Install with custom values

```bash
# From repository
helm install motion-tools motion-tools/motion-tools -f custom-values.yaml

# Direct install with custom values
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/' \
  motion-tools -f custom-values.yaml
```

### Install in a specific namespace

```bash
kubectl create namespace motion-tools
helm install motion-tools motion-tools/motion-tools --namespace motion-tools
```

## Testing with Kind

For local testing and development, you can use the provided Kind configuration:

```bash
# Create a kind cluster (if not already exists)
kind create cluster --config kind-config.yaml

# Deploy with test values
helm install motion-tools . -f values-test-kind.yaml

# Check deployment status
kubectl get pods -l app.kubernetes.io/instance=motion-tools

# Test the application
kubectl port-forward svc/motion-tools 8080:80
# Visit http://localhost:8080 in your browser

# Check logs
kubectl logs -l app.kubernetes.io/name=motion-tools
```

The test deployment includes:
- Motion Tools application with minimal resources
- MariaDB database (without persistence for faster testing)
- Valkey cache (CloudPirates chart v0.3.2)
- All services configured for local development

## Quick Start

1. **Basic installation with integrated database:**

```bash
helm install my-motion-tools motion-tools/motion-tools \
  --set motionTools.apacheFqdn=motion.example.com \
  --set motionTools.smtp.host=smtp.example.com \
  --set motionTools.smtp.from=noreply@example.com \
  --set motionTools.smtp.password=secretpassword \
  --set mariadb.auth.password=dbpassword
```

2. **Production installation with Ingress and TLS:**

```bash
helm install my-motion-tools motion-tools/motion-tools \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=motion.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --set ingress.tls[0].secretName=motion-tls \
  --set ingress.tls[0].hosts[0]=motion.example.com \
  --set motionTools.apacheFqdn=motion.example.com
```

## Configuration

The following table lists the configurable parameters and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas (must be 1) | `1` |
| `image.repository` | Image repository | `devopsansiblede/antragsgruen` |
| `image.tag` | Image tag | `""` (uses chart appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full name | `""` |

### Motion Tools Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `motionTools.timezone` | Application timezone | `Europe/Berlin` |
| `motionTools.apacheFqdn` | Apache FQDN | `motion.local` |
| `motionTools.smtp.enabled` | Enable SMTP | `true` |
| `motionTools.smtp.host` | SMTP host | `mail.example.com` |
| `motionTools.smtp.port` | SMTP port | `587` |
| `motionTools.smtp.from` | From email address | `motiontool@example.com` |
| `motionTools.smtp.password` | SMTP password | `""` |
| `motionTools.php.memoryLimit` | PHP memory limit | `256M` |
| `motionTools.php.maxExecutionTime` | PHP max execution time | `300` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mariadb.enabled` | Deploy MariaDB | `true` |
| `mariadb.auth.database` | Database name | `antragsgruen` |
| `mariadb.auth.username` | Database user | `antragsgruen` |
| `mariadb.auth.password` | Database password | `changeme` |
| `externalDatabase.host` | External database host | `""` |
| `externalDatabase.port` | External database port | `3306` |
| `externalDatabase.database` | External database name | `antragsgruen` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence using PVC | `true` |
| `persistence.accessMode` | PVC Access Mode (⚠️ MUST be ReadWriteOnce) | `ReadWriteOnce` |
| `persistence.size` | Volume size | `10Gi` |
| `persistence.storageClass` | Storage class | `""` (uses default) |
| `persistence.existingClaim` | Use existing PVC | `""` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podSecurityContext.fsGroup` | File system group | `33` |
| `podSecurityContext.runAsUser` | User ID | `33` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `true` |
| `networkPolicy.enabled` | Enable network policy | `false` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1024Mi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `512Mi` |

### Autoscaling

*Note: The Motion Tools application is designed for single-instance deployment.*

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA (must be false) | `false` |
| `autoscaling.minReplicas` | Min replicas | `1` |
| `autoscaling.maxReplicas` | Max replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `80` |

## Examples

### Using External Database

```yaml
# custom-values.yaml
mariadb:
  enabled: false

externalDatabase:
  host: mysql.example.com
  port: 3306
  database: motiontools
  username: motionuser
  password: secretpassword
```

### Enabling Valkey Cache (Redis-compatible)

This chart uses the CloudPirates Valkey Helm chart (v0.3.2) for Redis-compatible caching. The chart is available at `oci://registry-1.docker.io/cloudpirates/valkey`.

For more information about the CloudPirates Valkey chart, see: https://github.com/CloudPirates-io/helm-charts/tree/main/charts/valkey

```yaml
motionTools:
  valkey:
    enabled: true
    host: valkey.example.com
    port: 6379
    password: valkeypassword
```

When using the bundled Valkey deployment:

```yaml
valkey:
  enabled: true
  replicaCount: 1
  auth:
    enabled: true
    password: "changeme"
    # Use existing secret for password
    existingSecret: ""
    existingSecretPasswordKey: "password"
  config:
    maxMemory: "256mb"
    maxMemoryPolicy: "allkeys-lru"
```

### Production Configuration

```yaml
# production-values.yaml
replicaCount: 3

image:
  tag: "v4.15.3"

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: motion.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: motion-tls
      hosts:
        - motion.example.com

motionTools:
  apacheFqdn: motion.example.com
  smtp:
    enabled: true
    host: smtp.gmail.com
    port: 587
    from: noreply@example.com
    user: noreply@example.com
    existingSecret: smtp-credentials

persistence:
  size: 50Gi
  storageClass: fast-ssd

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 1Gi

mariadb:
  auth:
    existingSecret: db-credentials
  persistence:
    size: 20Gi
    storageClass: fast-ssd

networkPolicy:
  enabled: true
```

## Limitations

- **StatefulSet with Single Instance**: This chart uses a StatefulSet with exactly one replica
- **No High Availability**: The application runs as a single StatefulSet pod
- **Storage**: Uses `volumeClaimTemplates` with `ReadWriteOnce` access mode
- **Session Management**: Not designed for distributed session handling

## Upgrading

### From 0.x to 1.x

```bash
# Backup your data first
kubectl exec -it deployment/motion-tools -- mysqldump -h localhost -u root -p antragsgruen > backup.sql

# Upgrade from repository
helm upgrade motion-tools motion-tools/motion-tools

# Or upgrade from source
helm upgrade motion-tools .
```

## Uninstalling

```bash
helm uninstall motion-tools
```

To delete the persistent volume claims:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=motion-tools
```

## Troubleshooting

### Pod is not starting

Check the pod logs:
```bash
kubectl logs -f deployment/motion-tools
```

### Database connection issues

Verify the database is running:
```bash
kubectl get pods -l app.kubernetes.io/name=mariadb
```

### Permission issues

Ensure the correct security context:
```bash
kubectl describe pod -l app.kubernetes.io/name=motion-tools
```

### Storage issues

Check PVC status:
```bash
kubectl get pvc
kubectl describe pvc motion-tools
```

## Validation

After deployment, validate that all components are working:

```bash
# Check all pods are running
kubectl get pods -l app.kubernetes.io/instance=motion-tools

# Test database connectivity
kubectl exec deployment/motion-tools -- nc -z motion-tools-mariadb 3306

# Test Valkey connectivity (if enabled)
kubectl exec deployment/motion-tools -- nc -z motion-tools-valkey 6379

# Test application response
kubectl exec deployment/motion-tools -- curl -s -I http://localhost/

# Check application logs for errors
kubectl logs deployment/motion-tools --tail=50
```

Expected healthy status:
- All pods should be in `Running` state with `1/1` ready
- HTTP response should return `200 OK`
- No error messages in application logs related to database or cache connectivity

## Advanced Features

### Background Jobs

Enable background job processing for improved performance:

```yaml
motionTools:
  backgroundJobs:
    enabled: true
    notifications: true
    healthCheckKey: "your-health-check-key"
```

### PDF Rendering

Configure advanced PDF rendering engines:

```yaml
motionTools:
  pdfRendering:
    engine: weasyprint  # Options: tcpdf, weasyprint, latex
    weasyprintPath: /usr/bin/weasyprint
```

## Support

- **Motion Tools Documentation**: https://motion.tools
- **GitHub Repository**: https://github.com/CatoTH/antragsgruen
- **Chart Issues**: Please report issues with this Helm chart in the chart repository

## License

This Helm chart is provided as-is. Motion Tools (Antragsgrün) is licensed under the AGPL-3.0 license.

## Chart Repository Hosting

This chart is hosted on Cloudsmith for easy distribution and installation.

### Publishing to Cloudsmith

To publish a new version of this chart to Cloudsmith:

```bash
# Package the chart
helm package .

# Upload to Cloudsmith (requires authentication)
cloudsmith push helm tielbeke/motion-tools-helm motion-tools-0.1.0.tgz
```

### Repository Information

- **Repository URL**: `https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/`
- **Package Manager**: Helm
- **Access**: Public
- **Provider**: Cloudsmith

### Alternative Installation Methods

```bash
# Method 1: Add repository first (recommended)
helm repo add motion-tools https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/
helm repo update
helm install motion-tools motion-tools/motion-tools

# Method 2: Direct install without adding repo
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/' \
  motion-tools

# Method 3: Install specific version
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/gD4hJYGsq4zGYdnQ/tielbeke/motion-tools-helm/helm/charts/' \
  motion-tools --version 0.1.0
```

### Updating Chart Versions

1. Update the `version` in `Chart.yaml`
2. Update `appVersion` if the application version changed
3. Add change notes to `artifacthub.io/changes` annotation
4. Package and upload the new version

For more information about Cloudsmith Helm repositories, see: https://help.cloudsmith.io/docs/helm-chart-repository

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
