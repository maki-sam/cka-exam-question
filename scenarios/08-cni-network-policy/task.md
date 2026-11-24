Install a CNI with NetworkPolicy support

The dedicated kind-cni-lab cluster has no CNI. Its pod CIDR is 192.168.0.0/16.

Choose between Flannel (connectivity only) and Calico (connectivity and policy enforcement).

Install Calico v3.33.0 using its CRDs, operator and custom-resources manifests:

https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/v3_projectcalico_org-v1beta1.yaml

https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/tigera-operator.yaml

https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/custom-resources.yaml

Ensure the Installation uses the cluster's pod CIDR and wait for the node to become Ready.

Confirm the calico-node DaemonSet is ready before testing a NetworkPolicy.

Continue to **Solution and review** when you want hints. Completion is self-assessed; there is no automatic grading.
