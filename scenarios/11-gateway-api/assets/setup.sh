#!/bin/bash
set -euo pipefail

echo "🚀 Setting up Kubernetes Gateway API migration lab..."

# Install Envoy Gateway with its matching CRDs.
helm upgrade --install eg oci://docker.io/envoyproxy/gateway-helm \
  --version v1.9.4 --namespace envoy-gateway-system --create-namespace \
  --wait --timeout 240s

# 2. Deploy a simple nginx web app
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
EOF

# 3. Create a service for the web app
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
EOF

# 4. Create a self-signed TLS certificate and secret
echo "🔐 Creating TLS certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=gateway.web.k8s.local/O=web" >/dev/null 2>&1

kubectl create secret tls web-tls --cert=tls.crt --key=tls.key >/dev/null
rm -f tls.crt tls.key

# 5. Create an existing Ingress resource (to migrate from)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF

# 6. Create a GatewayClass backed by Envoy Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-class
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

echo
echo "✅ Gateway API lab setup complete!"
echo
echo "Resources created:"
echo "  - Deployment: web-deployment"
echo "  - Service: web-service"
echo "  - Ingress: web"
echo "  - GatewayClass: nginx-class"
echo
echo "🎯 Next steps:"
echo "  1️⃣  Create a Gateway named web-gateway using hostname gateway.web.k8s.local and nginx-class."
echo "  2️⃣  Create a HTTPRoute named web-route referencing web-service."
echo "  3️⃣  Use 'kubectl get gatewayclass,gateway,httproute -A' to verify."
