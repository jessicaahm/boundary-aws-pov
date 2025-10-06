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
kubectl get pod --certificate-authority=ca.crt --server=https://127.0.0.1:$PORT --token=$REMOTE_USER_TOKEN -n game-2048

# Create a target in Boundary to access the eks cluster
KUBE_TARGET_ID=$(boundary targets create tcp \
    -name="kubernetes-api" \
    -description="Kubernetes API" \
    -default-port=443 \
    -scope-id=$KUBE_PROJ_ID \
    -address=$(echo $KUBE_API_URL | cut -c 8-) \
    -session-connection-limit="-1" \
    -format json | jq -r '.item | .id') && echo $KUBE_TARGET_ID

```

## Reference

https://www.hashicorp.com/en/blog/how-to-connect-to-kubernetes-clusters-using-boundary