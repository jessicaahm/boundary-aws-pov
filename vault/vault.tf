terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.3.0"
   }
   kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  boundary = {
      source  = "hashicorp/boundary"
      version = "1.3.1"
    }
 }
}

provider "boundary" {
  addr                   = var.boundary_addr
  tls_insecure           = var.tls_insecure
  auth_method_id         = var.global_auth_method_id
  auth_method_login_name = var.global_admin_login_name
  auth_method_password   = var.global_admin_password
}

provider "vault" {
    address = var.vault_addr
    namespace = "admin"
}

# For Kubernetes Secret Engine
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = file("${path.module}/ca.crt")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "eks-cluster"]
    command     = "aws"
  }
}

# Create a namespace for boundary to integrate with vault
resource "vault_namespace" "vault_namespace" {
  path = "vault"
}

# get the short term token
resource "kubernetes_token_request_v1" "vault_sa_token" {
  metadata {
    name = "vault" #based on the vault-cluster-role.yaml
    namespace = "vault" #based on the vault-cluster-role.yaml
  }
  spec {
    audiences          = ["https://kubernetes.default.svc","game-2048","vault"]
    expiration_seconds = 86400  # 24 hours instead of 1 hour
  }
}

# enable and configure kubernetes secret engine
resource "vault_kubernetes_secret_backend" "config" {

  namespace                 = vault_namespace.vault_namespace.path 
  path                      = "kubernetes"
  description               = "kubernetes secrets engine description"
  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 86400
  kubernetes_host           = var.cluster_endpoint
  kubernetes_ca_cert        = file("${path.module}/ca.crt")
  service_account_jwt       = kubernetes_token_request_v1.vault_sa_token.token
  disable_local_ca_jwt      = false
}

# create a vault role that can generate service account tokens for the given service account
resource "vault_kubernetes_secret_backend_role" "k8s-role" {
  namespace                     = vault_namespace.vault_namespace.path
  backend                       = vault_kubernetes_secret_backend.config.path
  name                          = "vault-service-account-name-role"
  allowed_kubernetes_namespaces = ["*"]
  token_max_ttl                 = 43200
  token_default_ttl             = 21600
  generated_role_rules          = <<EOF
  {
    "rules":[
      {
      "apiGroups":[""],
      "resources":["pods"],
      "verbs":["list"]
      }
]
  }
  EOF
}

# create policy for boundar
resource "vault_policy" "boundary-controller" {
  namespace = vault_namespace.vault_namespace.path
  name = "support-team"

  policy = <<EOT
 path "auth/token/lookup-self" {
   capabilities = ["read"]
 }

 path "auth/token/renew-self" {
   capabilities = ["update"]
 }

 path "auth/token/revoke-self" {
   capabilities = ["update"]
 }

 path "sys/leases/renew" {
   capabilities = ["update"]
 }

 path "sys/leases/revoke" {
   capabilities = ["update"]
 }

 path "sys/capabilities-self" {
   capabilities = ["update"]
 }

 path "kubernetes/creds/vault-service-account-name-role" {
   capabilities = ["update"]
 }
EOT
}

# Create an orphan token for use by boundary
resource "vault_token" "orphan_token" {
  namespace = vault_namespace.vault_namespace.path
  policies  = [vault_policy.boundary-controller.name]
  no_parent = true
  period       = "1h"
  renewable = true
  no_default_policy = true


  metadata  = {
    "purpose" = "service-account"
  }
}

# create credential store in boundary for vault
resource "boundary_credential_store_vault" "vault_credstore" {
  namespace   = "/admin/vault"
  name        = "vault-credstore"
  description = "My first Vault credential store!"
  address     = var.vault_addr     # change to Vault address
  token       = vault_token.orphan_token.client_token # change to valid Vault token
  scope_id    = var.project_id
  tls_skip_verify = true
}

# create credential library in boundary for vault
resource "boundary_credential_library_vault" "k8s_credlib" {
  name                = "k8s-credlib"
  description         = "kubernetes engine cred lib in vault"
  credential_store_id = boundary_credential_store_vault.vault_credstore.id
  path                = "kubernetes/creds/vault-service-account-name-role" # change to Vault backend path
  http_method         = "POST"
  http_request_body   = <<EOT
{
  "kubernetes_namespace": "game-2048"	
}
EOT

}