Steps:

1. To deploy controller: https://github.com/jessicaahm/demo-boundary-controller-aws
2. bootstraps controller: https://github.com/jessicaahm/terraform-boundary-bootstrap-hvd.git
3. Deploy worker: https://github.com/jessicaahm/terraform-aws-boundary-enterprise-worker-hvd
4. Use cases

```powershell
### In Windows ###
# Set Environment Variable
$env:BOUNDARY_TLS_INSECURE = "true"
$env:BOUNDARY_ADDR = "$BOUNDARY_ADDR"

# Authenticate with password
boundary authenticate password -auth-method-id $PWD_AUTH_METHOD_ID 

# Connect with SSH (Injection)
boundary connect ssh -target-id $TARGET_ID -- -l ec2-user

# Authenticate with OIDC
boundary authenticate oidc -auth-method-id $OIDC_AUTH_METHOD_ID
```

References:

- [AMAZON IP RANGE](https://ip-ranges.amazonaws.com/ip-ranges.json)
- [DATA ENCRYPTION BOUNDARY](https://developer.hashicorp.com/boundary/docs/secure/encryption/data-encryption)