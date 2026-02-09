[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/motion-tools)](https://artifacthub.io/packages/search?repo=motion-tools)

# Motion Tools Helm Chart

A Helm chart for deploying [Motion Tools (Antragsgrün)](https://github.com/CatoTH/antragsgruen) on Kubernetes. Motion Tools is an online platform for NGOs, political parties, and social initiatives to collaboratively discuss resolutions, party platforms, and amendments.

## Features

- **Sidecar Architecture**: Two-container pod with PHP-FPM and NGINX for separation of concerns
- **12-Factor Configuration**: All application settings via environment variables
- **Database Management**: Integrated MariaDB or external database support
- **Caching**: Optional Valkey (Redis-compatible) integration
- **Security**: Built-in security configurations and network policies
- **Monitoring**: Health checks and probes configured for both containers
- **Customizable**: Extensive configuration options via Helm values

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

### Install with custom values

A `app.randomSeed` is required for all installations. Generate one first:

```bash
openssl rand -base64 32
```

```bash
# From repository
helm install motion-tools tielbeke-motion-tools-helm/motion-tools -f custom-values.yaml

# Direct install without adding repository
helm install motion-tools \
  --repo 'https://dl.cloudsmith.io/public/tielbeke/tielbeke/helm/charts/' \
  motion-tools -f custom-values.yaml
```

### Install in a specific namespace

```bash
kubectl create namespace motion-tools
helm install motion-tools tielbeke-motion-tools-helm/motion-tools \
  --namespace motion-tools -f custom-values.yaml
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

# Check logs (both containers)
kubectl logs -l app.kubernetes.io/name=motion-tools -c motion-tools-php
kubectl logs -l app.kubernetes.io/name=motion-tools -c motion-tools-nginx
```

The test deployment includes:
- Motion Tools application (PHP-FPM + NGINX sidecar)
- MariaDB database (without persistence for faster testing)
- All services configured for local development

## Quick Start

1. **Basic installation with integrated database:**

```yaml
# basic-values.yaml
app:
  randomSeed: "<generate with: openssl rand -base64 32>"
  domain: "motion.example.com"
```

```bash
helm install motion-tools tielbeke-motion-tools-helm/motion-tools -f basic-values.yaml
```

2. **Installation with SMTP:**

```yaml
# smtp-values.yaml
app:
  randomSeed: "<generate with: openssl rand -base64 32>"
  domain: "motion.example.com"
  smtp:
    enabled: true
    host: "smtp.example.com"
    port: 587
    username: "noreply@example.com"
    password: "smtppassword"
    encryption: "tls"
  mail:
    fromEmail: "noreply@example.com"
    fromName: "Motion Tools"
```

```bash
helm install motion-tools tielbeke-motion-tools-helm/motion-tools -f smtp-values.yaml
```

3. **Production installation with Ingress and TLS:**

```yaml
# production-values.yaml
app:
  randomSeed: "<generate with: openssl rand -base64 32>"
  domain: "motion.example.com"
  protocol: "https"

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
```

```bash
helm install motion-tools tielbeke-motion-tools-helm/motion-tools -f production-values.yaml
```

## Configuration

The following tables list the configurable parameters and their default values.

### Images

| Parameter | Description | Default |
|-----------|-------------|---------|
| `images.php.repository` | PHP-FPM image repository | `ghcr.io/antoinetielbeke/motion-tools-php` |
| `images.php.tag` | PHP-FPM image tag | `""` (uses chart appVersion) |
| `images.php.pullPolicy` | PHP-FPM image pull policy | `IfNotPresent` |
| `images.nginx.repository` | NGINX image repository | `ghcr.io/antoinetielbeke/motion-tools-nginx` |
| `images.nginx.tag` | NGINX image tag | `""` (uses chart appVersion) |
| `images.nginx.pullPolicy` | NGINX image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full name | `""` |
| `serviceAccount.create` | Create a service account | `true` |
| `serviceAccount.name` | Service account name | `""` |

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.randomSeed` | **Required.** Security seed (generate with `openssl rand -base64 32`) | `""` |
| `app.existingSecretRandomSeed` | Use an existing secret for the random seed instead | `""` |
| `app.randomSeedSecretKey` | Key in the existing secret containing the random seed | `"random-seed"` |
| `app.domain` | Application domain | `"motion.local"` |
| `app.protocol` | Application protocol | `"https"` |
| `app.baseLanguage` | Base language | `"en"` |
| `app.multisiteMode` | Enable multisite mode | `false` |
| `app.runMigrations` | Run database migrations on startup | `true` |

### Single-Site Mode

Used when `app.multisiteMode` is `false`.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.singleSite.subdomain` | Site subdomain | `"std"` |
| `app.singleSite.title` | Site title | `"Demo Site"` |
| `app.singleSite.consultationPath` | Consultation URL path | `"main"` |
| `app.singleSite.consultationTitle` | Consultation title | `"Main Consultation"` |
| `app.singleSite.consultationTitleShort` | Consultation short title | `"Main"` |

### Mail Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.mailerDsn` | Symfony Mailer DSN (recommended, e.g. `smtp://user:pass@host:587`) | `""` |
| `app.smtp.enabled` | Enable SMTP (constructs DSN if `mailerDsn` is empty) | `false` |
| `app.smtp.host` | SMTP host | `""` |
| `app.smtp.port` | SMTP port | `""` |
| `app.smtp.username` | SMTP username | `""` |
| `app.smtp.password` | SMTP password | `""` |
| `app.smtp.encryption` | SMTP encryption (`tls`) | `""` |
| `app.mail.fromEmail` | Sender email address | `""` |
| `app.mail.fromName` | Sender display name | `""` |
| `app.extraEnvVars` | Additional environment variables for the PHP-FPM container | `[]` |
| `app.extraEnvFrom` | Additional envFrom sources (ConfigMaps/Secrets) | `[]` |

### NGINX Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nginx.rootRedirect` | Root path redirect (auto-set in single-site mode) | `""` |
| `nginx.serverName` | NGINX server name | `"_"` |
| `nginx.clientMaxBodySize` | Maximum request body size | `"32M"` |
| `nginx.fastcgi.connectTimeout` | FastCGI connect timeout | `"60s"` |
| `nginx.fastcgi.sendTimeout` | FastCGI send timeout | `"300s"` |
| `nginx.fastcgi.readTimeout` | FastCGI read timeout | `"300s"` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mariadb.enabled` | Deploy integrated MariaDB | `true` |
| `mariadb.auth.rootPassword` | MariaDB root password | `"changeme"` |
| `mariadb.auth.database` | Database name | `"antragsgruen"` |
| `mariadb.auth.username` | Database user | `"antragsgruen"` |
| `mariadb.auth.password` | Database password | `"changeme"` |
| `mariadb.auth.existingSecret` | Use existing secret for passwords | `""` |
| `externalDatabase.host` | External database host | `""` |
| `externalDatabase.port` | External database port | `3306` |
| `externalDatabase.database` | External database name | `"antragsgruen"` |
| `externalDatabase.username` | External database user | `"antragsgruen"` |
| `externalDatabase.password` | External database password | `""` |
| `externalDatabase.existingSecret` | Existing secret for external DB password | `""` |

### Valkey (Redis-compatible) Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `valkey.enabled` | Deploy Valkey | `false` |
| `valkey.replicaCount` | Number of Valkey replicas | `1` |
| `valkey.auth.enabled` | Enable authentication | `true` |
| `valkey.auth.password` | Valkey password | `"changeme"` |
| `valkey.config.maxMemory` | Maximum memory | `"256mb"` |
| `valkey.persistence.enabled` | Enable Valkey persistence | `true` |
| `valkey.persistence.size` | Valkey volume size | `8Gi` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.runtime.enabled` | Enable runtime volume (cache, sessions) | `true` |
| `persistence.runtime.accessMode` | Runtime volume access mode | `ReadWriteOnce` |
| `persistence.runtime.size` | Runtime volume size | `5Gi` |
| `persistence.runtime.storageClass` | Runtime volume storage class | `""` |
| `persistence.assets.enabled` | Enable assets volume (uploaded files) | `true` |
| `persistence.assets.accessMode` | Assets volume access mode | `ReadWriteOnce` |
| `persistence.assets.size` | Assets volume size | `10Gi` |
| `persistence.assets.storageClass` | Assets volume storage class | `""` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podSecurityContext` | Pod security context | `{}` |
| `securityContext` | Container security context | `{}` |
| `networkPolicy.enabled` | Enable network policy | `false` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `php.resources.limits.cpu` | PHP-FPM CPU limit | `1000m` |
| `php.resources.limits.memory` | PHP-FPM memory limit | `1024Mi` |
| `php.resources.requests.cpu` | PHP-FPM CPU request | `250m` |
| `php.resources.requests.memory` | PHP-FPM memory request | `512Mi` |
| `nginx.resources.limits.cpu` | NGINX CPU limit | `500m` |
| `nginx.resources.limits.memory` | NGINX memory limit | `256Mi` |
| `nginx.resources.requests.cpu` | NGINX CPU request | `100m` |
| `nginx.resources.requests.memory` | NGINX memory request | `128Mi` |

### Health Probes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.httpGet.path` | Liveness probe path | `/health` |
| `livenessProbe.initialDelaySeconds` | Liveness initial delay | `30` |
| `readinessProbe.httpGet.path` | Readiness probe path | `/health` |
| `readinessProbe.initialDelaySeconds` | Readiness initial delay | `20` |
| `startupProbe.httpGet.path` | Startup probe path | `/health` |
| `startupProbe.failureThreshold` | Startup probe max retries | `30` |

## Examples

### Using External Database

```yaml
# external-db-values.yaml
app:
  randomSeed: "<generate with: openssl rand -base64 32>"
  domain: "motion.example.com"

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
app:
  randomSeed: "<generate with: openssl rand -base64 32>"
  domain: "motion.example.com"
  protocol: "https"

  smtp:
    enabled: true
    host: smtp.gmail.com
    port: 587
    username: noreply@example.com
    encryption: "tls"
    existingSecret: smtp-credentials
  mail:
    fromEmail: noreply@example.com
    fromName: "Motion Tools"

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

persistence:
  runtime:
    size: 10Gi
    storageClass: fast-ssd
  assets:
    size: 50Gi
    storageClass: fast-ssd

php:
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
- **No High Availability**: The application runs as a single StatefulSet pod with two containers
- **Storage**: Uses `volumeClaimTemplates` with `ReadWriteOnce` access mode

## Upgrading

### From 0.x to 1.x

Version 1.0 is a complete rewrite of the chart with several breaking changes:

- **Architecture**: Monolithic Apache+PHP image replaced by a two-container sidecar (PHP-FPM + NGINX)
- **Configuration**: `motionTools.*` values replaced by `app.*` with native environment variables
- **Persistence**: Single volume split into separate `runtime` and `assets` volumes
- **Security**: New required `app.randomSeed` parameter
- **Images**: `devopsansiblede/antragsgruen` replaced by `ghcr.io/antoinetielbeke/motion-tools-php` and `motion-tools-nginx`

Because of these changes, the easiest migration path is a **backup and fresh install**.

#### Step 1: Backup your database

```bash
# If using the integrated MariaDB
kubectl exec -it statefulset/motion-tools-mariadb -- \
  mysqldump -u root -p antragsgruen > backup.sql

# If using an external database, use your existing backup method
```

#### Step 2: Note your current configuration

```bash
# Save your current values for reference
helm get values motion-tools -o yaml > old-values.yaml
```

#### Step 3: Uninstall the old release

```bash
helm uninstall motion-tools

# Delete the old PVCs (the data layout is incompatible with 1.x)
kubectl delete pvc -l app.kubernetes.io/instance=motion-tools
```

#### Step 4: Generate a random seed

This is a new requirement in 1.x used for application security.

```bash
openssl rand -base64 32
```

#### Step 5: Create your new values file

Map your old `motionTools.*` values to the new `app.*` structure:

```yaml
# new-values.yaml

app:
  randomSeed: "<output from step 4>"
  domain: "motion.example.com"        # was motionTools.apacheFqdn
  protocol: "https"

  # SMTP (was motionTools.smtp.*)
  smtp:
    enabled: true
    host: "smtp.example.com"           # was motionTools.smtp.host
    port: 587                          # was motionTools.smtp.port
    username: "user@example.com"       # was motionTools.smtp.user
    password: "smtppassword"           # was motionTools.smtp.password
    encryption: "tls"                  # was motionTools.smtp.tls: true

  mail:
    fromEmail: "noreply@example.com"   # was motionTools.smtp.from

# Database settings carry over as-is
mariadb:
  auth:
    password: "your-db-password"
```

The full mapping of old to new values:

| Old (0.x) | New (1.x) |
|-----------|-----------|
| `motionTools.apacheFqdn` | `app.domain` |
| `motionTools.timezone` | Removed (baked into image) |
| `motionTools.smtp.enabled` | `app.smtp.enabled` |
| `motionTools.smtp.host` | `app.smtp.host` |
| `motionTools.smtp.port` | `app.smtp.port` |
| `motionTools.smtp.user` | `app.smtp.username` |
| `motionTools.smtp.password` | `app.smtp.password` |
| `motionTools.smtp.tls: true` | `app.smtp.encryption: "tls"` |
| `motionTools.smtp.from` | `app.mail.fromEmail` |
| `persistence.size` | `persistence.runtime.size` + `persistence.assets.size` |
| `resources.*` | `php.resources.*` + `nginx.resources.*` |
| `image.repository` | `images.php.repository` + `images.nginx.repository` |

#### Step 6: Install the new version

```bash
helm install motion-tools tielbeke-motion-tools-helm/motion-tools -f new-values.yaml
```

#### Step 7: Restore your database

```bash
# Wait for MariaDB to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=mariadb --timeout=120s

# Restore the backup
kubectl exec -i statefulset/motion-tools-mariadb -- \
  mysql -u root -p antragsgruen < backup.sql
```

#### Step 8: Verify

```bash
# Both containers (PHP-FPM + NGINX) should be running
kubectl get pods -l app.kubernetes.io/name=motion-tools

# Should show 2/2 READY
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

Check the pod logs for each container:
```bash
# PHP-FPM logs
kubectl logs -f statefulset/motion-tools -c motion-tools-php

# NGINX logs
kubectl logs -f statefulset/motion-tools -c motion-tools-nginx

# Init container logs (copies static files to shared volume)
kubectl logs statefulset/motion-tools -c init-static-files
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
kubectl get pvc -l app.kubernetes.io/instance=motion-tools
```

## Validation

After deployment, validate that all components are working:

```bash
# Check all pods are running (should show 2/2 READY for the app pod)
kubectl get pods -l app.kubernetes.io/instance=motion-tools

# Test database connectivity
kubectl exec statefulset/motion-tools -c motion-tools-php -- nc -z motion-tools-mariadb 3306

# Test application response via NGINX
kubectl exec statefulset/motion-tools -c motion-tools-nginx -- curl -s -I http://localhost/health

# Check application logs for errors
kubectl logs statefulset/motion-tools -c motion-tools-php --tail=50
```

Expected healthy status:
- App pod should be in `Running` state with `2/2` ready (PHP-FPM + NGINX)
- MariaDB pod should be in `Running` state with `1/1` ready
- HTTP response to `/health` should return `200 OK`
- No error messages in application logs related to database connectivity

## Configuration Philosophy

This Helm chart follows 12-factor app principles. The application is configured entirely through environment variables (`APP_DOMAIN`, `APP_PROTOCOL`, `MAILER_DSN`, etc.) which are derived from the `app.*` section in your values file. The two-container sidecar design separates PHP-FPM (application logic) from NGINX (HTTP serving), allowing independent resource tuning and clearer separation of concerns.

## Support

- **Motion Tools Documentation**: https://motion.tools
- **GitHub Repository**: https://github.com/CatoTH/antragsgruen
- **Chart Issues**: Please report issues with this Helm chart in the chart repository

## License

This Helm chart is provided as-is. Motion Tools (Antragsgrün) is licensed under the AGPL-3.0 license.

## Chart Repository Hosting

This chart is hosted on Cloudsmith, a European artifact repository, for easy distribution and installation.

- **Repository URL**: `https://dl.cloudsmith.io/public/tielbeke/tielbeke/helm/charts/`

## Roadmap

The following features are planned for future releases of this Helm chart:

- [ ] Make config.json configurable via Helm values

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
