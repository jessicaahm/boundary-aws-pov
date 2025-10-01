# Set up Vault for Kubernetes

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


```

## Reference

https://www.hashicorp.com/en/blog/how-to-connect-to-kubernetes-clusters-using-boundary