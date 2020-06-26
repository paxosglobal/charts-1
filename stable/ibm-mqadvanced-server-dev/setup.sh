# DO NOT EXECUTE THIS SCRIPT! It's basically a dev log. Copy and paste as needed. TODO: helm'ize

# required step outside of helm deploy https://github.com/IBM/charts/tree/master/stable/ibm-mqadvanced-server-dev#creating-a-secret-to-store-queue-manager-credentials
kubectl -n dev-ibm-mqadvanced-server-dev apply -f mq-secret.yaml

helm install --name ibm-mqadvanced-server-dev /Users/johnamicangelo/src/github.com/paxosglobal/charts-1/stable/ibm-mqadvanced-server-dev/ibm-mqadvanced-server-dev-6.0.8.tgz \
  --namespace dev-ibm-mqadvanced-server-dev \
  --set license=accept \
  --set queueManager.dev.secret.name=mq-secret \
  --set queueManager.dev.secret.adminPasswordKey=adminPassword \ # not actually the password value; it's the name of the password key
  --set persistence.enabled=false \ # TODO: OpenShift pvc -> something that works on EKS
  --set log.debug=true

# push a pod up w/ curl installed to make sure admin web portal and queue manager are accessible
kubectl -n dev-ibm-mqadvanced-server-dev attach curl-6bf6db5c4f-hwvqw -c curl -i -t

# commands to run once inside
curl -k https://172.20.141.68:9443
curl -k https://internal-a1b1d796979944b948564cc9591436f7-802031894.us-east-1.elb.amazonaws.com:9443

# make service ports accessible outside k8s cluster but only inside the itbitnonprod VPN
kubectl -n dev-ibm-mqadvanced-server-dev expose service ibm-mqadvanced-server-dev-ibm-mq \
    --port=9443 \
    --type LoadBalancer \
    --name exposed-webserver

kubectl -n dev-ibm-mqadvanced-server-dev expose service ibm-mqadvanced-server-dev-ibm-mq \
    --port=1414 \
    --type LoadBalancer \
    --name exposed-mq

# HACK until helm'ized: manually add the following annotation to each exposed service:
# service.beta.kubernetes.io/aws-load-balancer-internal: "true"
