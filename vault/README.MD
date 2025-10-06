# Set up Vault for Kubernetes

Pre-req:
- Deploy EKS first

Run this to set up:
1. Kubernetes Secret Engine
2. Integrate Vault with Boundary to create creds store
3. Set up a target to access eks
4. Test end-to-end connectivity from boundary -> eks

```sh
# Create a Vault Namespace
kubectl create namespace vault

# Create Vault service account and cluster role in the vault namespace
kubectl apply -f vault-cluster-role.yaml

# Apply Terraform
terraform apply -auto-approve

# Test if the token works with kubectl
export REMOTE_USER_TOKEN=$(vault write kubernetes/creds/vault-service-account-name-role \
    kubernetes_namespace=game-2048 -format=json | jq -r '.data.service_account_token')
kubectl get pod --certificate-authority=ca.crt --server=$KUBE_API_URL --token=$REMOTE_USER_TOKEN -n game-2048
kubectl get node --certificate-authority=ca.crt --server=$KUBE_API_URL --token=$REMOTE_USER_TOKEN -n game-2048

# test 
kubectl get pod --insecure-skip-tls-verify --server=https://127.0.0.1:$PORT --token=$REMOTE_USER_TOKEN -n game-2048
kubectl get pod --certificate-authority=ca.crt --server=$KUBE_API_URL --token=$REMOTE_USER_TOKEN -n game-2048

# expected output
# NAME                              READY   STATUS    RESTARTS   AGE
# deployment-2048-bdbddc878-6b54f   1/1     Running   0          4d17h
# deployment-2048-bdbddc878-gt8n7   1/1     Running   0          4d17h
# deployment-2048-bdbddc878-h2whn   1/1     Running   0          4d17h
# deployment-2048-bdbddc878-t2fhc   1/1     Running   0          4d17h
# deployment-2048-bdbddc878-vkb8k   1/1     Running   0          4d17h

# Create a target in Boundary to access the eks cluster
KUBE_TARGET_ID=$(boundary targets create tcp \
    -name="kubernetes-api" \
    -description="Kubernetes API" \
    -default-port=443 \
    -scope-id=$KUBE_PROJ_ID \
    -address=$(echo $KUBE_API_URL | cut -c 8-) \
    -session-connection-limit="-1" \
    -format json | jq -r '.item | .id') && echo $KUBE_TARGET_ID

boundary targets authorize-session \
     -id $KUBE_TARGET_ID \
     -format json | jq -r '.item | .credentials[] | .secret | .decoded | .service_account_token') \
     && echo $BROKERED_KUBE_TOKEN

```

## Commo Error:
https://support.hashicorp.com/hc/en-us/articles/42413506765715-Error-in-HCP-Boundary-Target-Access-vaultClientFactory-vault-newClient-invalid-configuration-parameter-violation-error-100

## Reference

https://www.hashicorp.com/en/blog/how-to-connect-to-kubernetes-clusters-using-boundary

https://developer.hashicorp.com/boundary/tutorials/kubernetes-connect/kubernetes-getting-started-connect