{{- define "common.label" -}}
project: {{.Values.appName}}
env: {{.Values.env | default "test"}}
{{- end -}}


{{- define "common.felabel" -}}
{{ include "common.label" . }}
role: "frontend"
{{- end -}}

{{- define "common.belabel" -}}
{{ include "common.label" . }}
role: "backend"
{{- end -}}