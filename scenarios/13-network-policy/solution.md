# Solution and review

Run commands selectively and inspect the results. Replace example values where instructed.

```bash
# Compare provided policies and pick the least permissive that matches requirements
cat /root/network-policies/network-policy-1.yaml   # allows all ingress (too open)
cat /root/network-policies/network-policy-2.yaml   # extra IP allowed (too open)
cat /root/network-policies/network-policy-3.yaml   # only app=frontend pods IN the frontend namespace allowed (AND selectors)
kubectl get pods -n frontend --show-labels         # confirm app=frontend label
kubectl apply -f /root/network-policies/network-policy-3.yaml
```
