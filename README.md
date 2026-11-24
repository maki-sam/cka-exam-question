# CKA practice scenarios for Killercoda

This repository contains 17 standalone practice scenarios. Each has an automatic
setup, a task page, and a solution page. Completion is self-assessed; there are no
CHECK-button graders yet.

## Publish on Killercoda

1. Push this repository, including `scenarios/` and `structure.json`, to a GitHub repository you control.
2. In [Killercoda Creator settings](https://killercoda.com/creators/get-started),
   connect that repository and select the branch you pushed. Follow the displayed
   deploy-key and webhook instructions where required.
3. Open the scenarios on your creator page. Killercoda discovers the `index.json`
   files listed in `structure.json`; no container image build is required.
4. Launch each scenario in a fresh session and wait for **Lab ready** before
   attempting the task. Test its solution before sharing the scenario publicly.

See the [official creator documentation](https://killercoda.com/creators) for
repository sync, environment images, assets, and startup scripts.

## Edit and validate

The `Question-*` folders are the source material. Edit their `LabSetUp.bash`,
`Questions.bash`, or `SolutionNotes.bash`, then regenerate and validate:

```bash
python3 scripts/build-killercoda.py
python3 scripts/validate-killercoda.py
```

Commit the source changes and generated `scenarios/` files together. The generator
uses Python's standard library. GitHub Actions checks generated-file freshness,
JSON configuration, referenced files, shell syntax, and whitespace on pushes and
pull requests. These are static checks, not Kubernetes integration tests.

The generated files are overwritten on rebuild. Change shared startup behavior
in `scripts/build-killercoda.py`. A failed startup writes
`/tmp/cka-setup/failed`; details are in `/tmp/cka-setup/setup.log`.

## Scenarios

| # | Topic | Environment / notes |
|---|-------|---------------------|
| 01 | MariaDB persistent storage | Retained PV, explicit classless PVC, node affinity |
| 02 | Argo CD | Preinstalled CRDs; Helm chart 7.7.3 rendering |
| 03 | Sidecar | Shared log volume and BusyBox container |
| 04 | Resource allocation | Size requests against actual node capacity |
| 05 | HPA | Installs metrics-server; lab-only insecure kubelet TLS |
| 06 | CRD discovery | cert-manager CRDs; no controller required |
| 07 | PriorityClass | Existing user priority is 1000 |
| 08 | CNI and NetworkPolicy | Ubuntu 4 GB; dedicated kind cluster without a CNI |
| 09 | cri-dockerd | Ubuntu with Docker; packaged runtime installation |
| 10 | Taints and tolerations | Two nodes; schedule specifically on node01 |
| 11 | Gateway API | Real Envoy Gateway controller; TLS via port forwarding |
| 12 | Ingress | Ingress manifest and NodePort test; no Ingress controller |
| 13 | NetworkPolicy | Namespace AND pod selectors restrict backend ingress |
| 14 | StorageClass | Class configuration only; does not install a provisioner |
| 15 | API server / etcd repair | Intentionally breaks the API server endpoint |
| 16 | NodePort | Service on port 30080 |
| 17 | TLS configuration | ConfigMap, nginx-service, and TLS 1.3 |

All except 08 and 09 use `kubernetes-kubeadm-2nodes`. Scenario 08 uses an isolated,
single-node kind cluster (Kubernetes 1.35) and Calico 3.33. Its NotReady node is
intentional until you install the CNI. This replaces the original exercise that
attempted to install a second CNI over the playground's existing network.
Scenario 11 retains the original `nginx-class` name but backs it with Envoy Gateway
1.9.4. Its Ingress is migration input; the solution tests the new Gateway.

## Manual playground use

On a fresh disposable Linux Kubernetes playground, from the cloned repository:

```bash
bash scripts/run-question.sh "Question-1 MariaDB-Persistent volume"
```

The helper works from any working directory when invoked by its full path. The
question name must exactly match its source directory. Question and solution files
are reading material, not scripts to execute wholesale. Native Killercoda startup
also supplies prerequisites (Helm, readiness checks, controlplane scheduling);
manual users must supply these themselves. Labs 08 and 09 require an Ubuntu VM
with Docker instead of an existing Kubernetes playground.

## Validation status and live smoke test

Local validation covers packaging and shell syntax only. Live Killercoda setup,
external downloads, and end-to-end solutions have not yet been verified.
Killercoda updates its Kubernetes images, so repeat this check after platform changes:

1. Launch each scenario; confirm setup reaches **Lab ready** without errors.
2. Complete the task using its solution and inspect the required resources.
3. For 01, verify the PVC binds to the retained PV and MariaDB becomes available.
4. For 05, confirm `kubectl top pods -n autoscale` works before checking HPA metrics.
5. For 08, confirm Calico and the node become Ready, then test policy enforcement.
6. For 11, test HTTPS through the Envoy service with the supplied port-forward commands.
7. For 13, test allowed frontend traffic and denied traffic from another namespace.
8. For 15, confirm the API fails initially and recovers after the endpoint repair.
9. For 17, confirm TLS 1.2 fails and TLS 1.3 succeeds after restarting nginx.

The labs intentionally modify cluster-wide resources and, in scenario 15, the
control-plane manifest. Use a new disposable environment for each attempt.
