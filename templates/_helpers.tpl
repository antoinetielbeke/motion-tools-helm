{{/*
Expand the name of the chart.
*/}}
{{- define "motion-tools.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "motion-tools.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "motion-tools.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "motion-tools.labels" -}}
helm.sh/chart: {{ include "motion-tools.chart" . }}
{{ include "motion-tools.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "motion-tools.selectorLabels" -}}
app.kubernetes.io/name: {{ include "motion-tools.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "motion-tools.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "motion-tools.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image name
*/}}
{{- define "motion-tools.image" -}}
{{- $registryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" $registryName $tag -}}
{{- end }}

{{/*
Database host
*/}}
{{- define "motion-tools.databaseHost" -}}
{{- if .Values.mariadb.enabled -}}
{{- if eq .Values.mariadb.architecture "replication" -}}
{{- printf "%s-%s-primary" (include "motion-tools.fullname" .) "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "motion-tools.fullname" .) "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- else -}}
{{- .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Database port
*/}}
{{- define "motion-tools.databasePort" -}}
{{- if .Values.mariadb.enabled -}}
3306
{{- else -}}
{{- .Values.externalDatabase.port -}}
{{- end -}}
{{- end -}}

{{/*
Database name
*/}}
{{- define "motion-tools.databaseName" -}}
{{- if .Values.mariadb.enabled -}}
{{- .Values.mariadb.auth.database -}}
{{- else -}}
{{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Database user
*/}}
{{- define "motion-tools.databaseUser" -}}
{{- if .Values.mariadb.enabled -}}
{{- .Values.mariadb.auth.username -}}
{{- else -}}
{{- .Values.externalDatabase.username -}}
{{- end -}}
{{- end -}}

{{/*
Valkey host
*/}}
{{- define "motion-tools.valkeyHost" -}}
{{- if .Values.valkey.enabled -}}
{{- if eq .Values.valkey.architecture "replication" -}}
{{- printf "%s-%s" (include "motion-tools.fullname" .) "valkey" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "motion-tools.fullname" .) "valkey" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- else -}}
{{- .Values.motionTools.valkey.host -}}
{{- end -}}
{{- end -}}

{{/*
Database password secret name
*/}}
{{- define "motion-tools.databaseSecretName" -}}
{{- if .Values.mariadb.enabled -}}
{{- if .Values.mariadb.auth.existingSecret -}}
{{- .Values.mariadb.auth.existingSecret -}}
{{- else -}}
{{- printf "%s-mariadb" (include "motion-tools.fullname" .) -}}
{{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
{{- .Values.externalDatabase.existingSecret -}}
{{- else -}}
{{- printf "%s-db" (include "motion-tools.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Database password secret key
*/}}
{{- define "motion-tools.databaseSecretPasswordKey" -}}
{{- if .Values.mariadb.enabled -}}
mariadb-password
{{- else -}}
{{- default "db-password" .Values.externalDatabase.userPasswordKey -}}
{{- end -}}
{{- end -}}

{{/*
SMTP secret name
*/}}
{{- define "motion-tools.smtpSecretName" -}}
{{- if .Values.motionTools.smtp.existingSecret -}}
{{- .Values.motionTools.smtp.existingSecret -}}
{{- else -}}
{{- printf "%s-smtp" (include "motion-tools.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Valkey secret name
*/}}
{{- define "motion-tools.valkeySecretName" -}}
{{- if .Values.motionTools.valkey.existingSecret -}}
{{- .Values.motionTools.valkey.existingSecret -}}
{{- else -}}
{{- printf "%s-valkey" (include "motion-tools.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
RabbitMQ secret name
*/}}
{{- define "motion-tools.rabbitMqSecretName" -}}
{{- if .Values.motionTools.liveServer.rabbitMqExistingSecret -}}
{{- .Values.motionTools.liveServer.rabbitMqExistingSecret -}}
{{- else -}}
{{- printf "%s-rabbitmq" (include "motion-tools.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the volume name for persistent storage
*/}}
{{- define "motion-tools.volumeName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- include "motion-tools.fullname" . -}}
{{- end -}}
{{- end -}}