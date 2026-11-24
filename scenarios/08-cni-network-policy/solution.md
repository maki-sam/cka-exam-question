# Solution and review

Run commands selectively and inspect the results. Replace example values where instructed.

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/v3_projectcalico_org-v1beta1.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/tigera-operator.yaml
kubectl wait --for=condition=Established crd/installations.operator.tigera.io --timeout=120s
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/custom-resources.yaml
kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl -n calico-system rollout status daemonset/calico-node --timeout=300s
kubectl get tigerastatus
```
