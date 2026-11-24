# Solution and review

Run commands selectively and inspect the results. Replace example values where instructed.

```bash
# Step 1: Inspect existing assets (host, secret, backend service/port)
kubectl describe ingress web
kubectl describe secret web-tls

# Step 2: Create Gateway (mirrors Ingress host + TLS)
cat <<'EOF' > gw.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
spec:
  gatewayClassName: nginx-class
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: gateway.web.k8s.local
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls
EOF
kubectl apply -f gw.yaml
kubectl get gateway

# Step 3: Create HTTPRoute (mirrors Ingress rules)
cat <<'EOF' > http.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - "gateway.web.k8s.local"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
EOF
kubectl apply -f http.yaml

# Step 4: Verify
kubectl describe gateway web-gateway
kubectl describe httproute web-route

# Killercoda has no cloud LoadBalancer; test through port forwarding.
kubectl -n envoy-gateway-system get svc
# Wait for the service owned by web-gateway to appear, then:
ENVOY_SERVICE=$(kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=web-gateway,gateway.envoyproxy.io/owning-gateway-namespace=default -o jsonpath='{.items[0].metadata.name}')
kubectl -n envoy-gateway-system port-forward "service/$ENVOY_SERVICE" 8443:443 &
# In a second terminal:
curl -k --resolve gateway.web.k8s.local:8443:127.0.0.1 https://gateway.web.k8s.local:8443/
```
