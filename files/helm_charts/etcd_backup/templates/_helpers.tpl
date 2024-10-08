{{/*
Define imageCredentials for private docker registry.
*/}}

{{- define "imagePullSecret" }}
{{- with .Values.image }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\", \"auth\":\"%s\"}}}" .registry .credentials.username .credentials.password (printf "%s:%s" .credentials.username .credentials.password | b64enc) | b64enc }}
{{- end }}
{{- end }}