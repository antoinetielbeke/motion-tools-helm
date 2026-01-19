[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/motion-tools)](https://artifacthub.io/packages/search?repo=motion-tools)

# Motion Tools Helm Chart

A Helm chart for deploying [Motion Tools (Antragsgrün)](https://github.com/CatoTH/antragsgruen) on Kubernetes. Motion Tools is an online platform for NGOs, political parties, and social initiatives to collaboratively discuss resolutions, party platforms, and amendments.

## Features

- **Easy Deployment**: Simple installation with sensible defaults
- **Database Management**: Integrated MariaDB or external database support
- **Security**: Built-in security configurations and network policies
- **Monitoring**: Health checks and probes configured
- **Customizable**: Extensive configuration options via environment variables

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- Optional: cert-manager for automatic TLS certificate management

## Installation

### Add the Helm repository

```bash
# Add the Motion Tools repository hosted on Cloudsmith
helm repo add tielbeke-motion-tools-helm 'https://dl.cloudsmith.io/public/tielbeke/tielbeke/helm/charts/'
helm repo update
```

### Install with default configuration

```bash
# From repository
helm install motion-tools tielbeke-motion-tools-helm/motion-tools

# Direct install without adding repository
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/public/tielbeke/tielbeke/helm/charts/' \
  motion-tools
```

### Install with custom values

```bash
# From repository
helm install motion-tools tielbeke-motion-tools-helm/motion-tools -f custom-values.yaml

# Direct install with custom values
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/public/tielbeke/tielbeke/helm/charts/' \
  motion-tools -f custom-values.yaml
```

### Install in a specific namespace

```bash
kubectl create namespace motion-tools
helm install motion-tools tielbeke-motion-tools-helm/motion-tools --namespace motion-tools
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
- All services configured for local development

## Quick Start

1. **Basic installation with integrated database:**

```bash
helm install my-motion-tools tielbeke-motion-tools-helm/motion-tools \
  --set motionTools.apacheFqdn=motion.example.com \
  --set mariadb.auth.password=dbpassword
```

2. **Installation with SMTP:**

```bash
helm install my-motion-tools tielbeke-motion-tools-helm/motion-tools \
  --set motionTools.apacheFqdn=motion.example.com \
  --set mariadb.auth.password=dbpassword \
  --set mariadb.auth.rootPassword=rootpassword \
  --set motionTools.smtp.enabled=true \
  --set motionTools.smtp.host=smtp.example.com \
  --set motionTools.smtp.port=587 \
  --set motionTools.smtp.from=noreply@example.com \
  --set motionTools.smtp.user=noreply@example.com \
  --set motionTools.smtp.password=smtppassword \
  --set motionTools.smtp.tls=true \
  --set motionTools.smtp.auth=true
```

3. **Production installation with Ingress and TLS:**

```bash
helm install my-motion-tools tielbeke-motion-tools-helm/motion-tools \
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

### PHP Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `php.uploadMaxFilesize` | Maximum upload file size | `500M` |
| `php.postMaxSize` | Maximum POST data size | `500M` |
| `php.maxExecutionTime` | Maximum execution time in seconds | `60` |
| `php.memoryLimit` | Memory limit for PHP scripts | `768M` |
| `php.maxInputTime` | Maximum input parsing time in seconds | `60` |

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
| `motionTools.timezone` | Application timezone | `Europe/Amsterdam` |
| `motionTools.apacheFqdn` | Apache FQDN | `motion.local` |
| `motionTools.smtp.enabled` | Enable SMTP (if disabled, local sendmail is used) | `false` |
| `motionTools.smtp.host` | SMTP host | `mail.example.com` |
| `motionTools.smtp.port` | SMTP port | `587` |
| `motionTools.smtp.from` | From email address | `motiontool@example.com` |
| `motionTools.smtp.user` | SMTP user | `motiontool@example.com` |
| `motionTools.smtp.password` | SMTP password | `""` |
| `motionTools.smtp.tls` | Enable TLS encryption | `false` |
| `motionTools.smtp.auth` | Enable SMTP authentication (required for most SMTP servers) | `false` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mariadb.enabled` | Deploy MariaDB | `true` |
| `mariadb.image.tag` | MariaDB image tag (version) | `""` (uses CloudPirates chart default) |
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

### Production Configuration

```yaml
# production-values.yaml

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
    tls: true
    auth: true
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
  # Specify MariaDB image version
  image:
    tag: ""  # Uses CloudPirates chart default if not specified
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

## Upgrading

### From 0.x to 1.x

```bash
# Backup your data first
kubectl exec -it deployment/motion-tools -- mysqldump -h localhost -u root -p antragsgruen > backup.sql

# Upgrade from repository
helm upgrade motion-tools tielbeke-motion-tools-helm/motion-tools

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

# Test application response
kubectl exec deployment/motion-tools -- curl -s -I http://localhost/

# Check application logs for errors
kubectl logs deployment/motion-tools --tail=50
```

Expected healthy status:
- All pods should be in `Running` state with `1/1` ready
- HTTP response should return `200 OK`
- No error messages in application logs related to database connectivity

## Configuration Philosophy

This Helm chart follows the docker-compose approach where the application is configured primarily through environment variables (TIMEZONE, APACHE_FQDN, SMTP settings). Advanced features like caching, PDF rendering, and background jobs are configured through the application's web interface or config.json file, which the Docker image manages internally.

## Support

- **Motion Tools Documentation**: https://motion.tools
- **GitHub Repository**: https://github.com/CatoTH/antragsgruen
- **Chart Issues**: Please report issues with this Helm chart in the chart repository

## License

This Helm chart is provided as-is. Motion Tools (Antragsgrün) is licensed under the AGPL-3.0 license.

## Chart Repository Hosting

This chart is hosted on Cloudsmith, an European artifact repository, for easy distribution and installation.

- **Repository URL**: `https://dl.cloudsmith.io/public/tielbeke/tielbeke/helm/charts/`

## Roadmap

The following features are planned for future releases of this Helm chart:

- [ ] Make config.json configurable via Helm values

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
