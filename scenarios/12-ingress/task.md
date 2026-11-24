Question Ingress



Task

1. Expose the existing deployment with a service called echo-service

using Service Port 8080 type=NodePort

2. Create a new ingress resource named echo in the echo-sound namespace for http://example.org/echo

3. The availability of the Service echo-service can be checked using the following command

`curl NODEIP:NODEPORT/echo`



This lab assesses the Ingress manifest and NodePort connectivity; no Ingress controller is installed.

In the exam it may give you a command like curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo

This requires an ingress controller, to get this to work ensure your /etc/hosts file has an entry for your NodeIP

pointing to example.org



Video Link - https://youtu.be/sy9zABvDedQ

Continue to **Solution and review** when you want hints. Completion is self-assessed; there is no automatic grading.
