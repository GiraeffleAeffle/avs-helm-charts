apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "arpa.fullname" . }}-register-job
  labels:
    {{- include "arpaRegister.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": "post-install"
spec:
  template:
    metadata:
      labels:
        {{- include "arpaRegister.labels" . | nindent 8 }}
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: {{ include "arpa.fullname" . }}
            topologyKey: "kubernetes.io/hostname"
      containers:
        - name: register
          image: "{{ .Values.register.image.repository }}:{{ .Values.register.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.register.image.pullPolicy }}
          args:
            {{- toYaml .Values.register.args | nindent 12 }}
          env:
            {{- toYaml .Values.node.env | nindent 12 }}
          volumeMounts:
            {{- toYaml .Values.node.volumeMounts | nindent 12 }}
      restartPolicy: Never
      volumes:
        {{- toYaml .Values.volumes | nindent 8 }}
        - name: config
          configMap:
            name: {{ include "arpa.fullname" . }}-config
  backoffLimit: 2