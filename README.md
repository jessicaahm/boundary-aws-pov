Steps:

1. To deploy controller: https://github.com/jessicaahm/demo-boundary-controller-aws
2. bootstraps controller: https://github.com/jessicaahm/terraform-boundary-bootstrap-hvd.git
3. Deploy worker: https://github.com/jessicaahm/terraform-aws-boundary-enterprise-worker-hvd
4. Use cases
    - Integrate Vault with EKS:
        - Set up eks: ./sample-eks-app
        - Integrate Vault with Boundary and set up K8S engine: ./vault

```sh
export $(cat .env | xargs)
```

```powershell
# Set Environment Variable
$env:BOUNDARY_TLS_INSECURE = "true"
$env:BOUNDARY_ADDR = "https://internal.jessica-ang.sbx.hashidemos.io/"
$env:TARGET_ID = "tssh_0ROa1Qq37e"
$env:PWD_AUTH_METHOD_ID = "ampw_Q3h2a7Wjkx"
$env:BOUNDARY_TLS_INSECURE = "true"
$env:BOUNDARY_SCOPE_ID = "p_U7d2ewBz68"
$env:BOUNDARY_LOG_LEVEL="trace"

# Authenticate with password
boundary authenticate password -auth-method-id $PWD_AUTH_METHOD_ID 

# List targets
boundary targets list -scope-id o_Bb1wlOIEc7 -recursive

# Connect with SSH (Injection)
boundary connect ssh -target-id tssh_OJcbLGsai4
boundary connect ssh -target-id tssh_0ROa1Qq37e

# Authenticate with OIDC
boundary authenticate oidc -auth-method-id $OIDC_AUTH_METHOD_ID

# Troubleshooting connectivity
ncat -v -z 10.0.7.86 9202 # Test connectivity to ingress workers from RDP
nc -v -z 10.0.10.136 9202 # Test connectivity to egress workers from ingress workers
```

```sh
# Test Host Catalog
HOST_SET_ID=$(terraform output -raw ssh_host_set_id)
boundary host-sets read -id $HOST_SET_ID

# connect to host
UBUNTU_USER=ec2_user
boundary connect ssh -target-id="tssh_xoDcr0eodA" # using injected credentials
```

References:

- [AMAZON IP RANGE](https://ip-ranges.amazonaws.com/ip-ranges.json)
- [DATA ENCRYPTION BOUNDARY](https://developer.hashicorp.com/boundary/docs/secure/encryption/data-encryption)