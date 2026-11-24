# Patch wordpress deployment to add shared volume + sidecar
cat <<'EOF' > /tmp/sidecar-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  template:
    spec:
      volumes:
      - name: log
        emptyDir: {}
      containers:
      - name: wordpress
        volumeMounts:
        - name: log
          mountPath: /var/log
      - name: sidecar
        image: busybox:stable
        command: ["/bin/sh","-c","touch /var/log/wordpress.log; tail -f /var/log/wordpress.log"]
        volumeMounts:
        - name: log
          mountPath: /var/log
EOF

kubectl patch deployment wordpress --type=strategic --patch-file=/tmp/sidecar-patch.yaml
kubectl rollout status deployment wordpress
kubectl get pods -l app=wordpress
