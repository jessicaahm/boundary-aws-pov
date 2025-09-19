terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.3.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.47.0"
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

# Create an organization scope
resource "boundary_scope" "org" {
  name                     = var.org_name
  description              = "USING AD FOR AUTH"
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# Create a project scope within the organization
resource "boundary_scope" "project_support" {
  name             = "IT_SUPPORT"
  description      = "IT SUPPORT FOR PROD"

  # scope_id is taken from the org resource defined for 'IT_Support'
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# Create a project scope within the organization
resource "boundary_scope" "project_developer" {
  name             = "DEVELOPER"
  description      = "DEVELOPER FOR PROD"

  # scope_id is taken from the org resource defined for 'IT_Support'
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# OIDC with EntraID
resource "boundary_auth_method_oidc" "provider" {
  name                 = "Azure"
  description          = "OIDC auth method for Azure"
  scope_id             = boundary_scope.org.id
  issuer               = var.oidc_issuer
  client_id            = var.oidc_client_id
  client_secret        = var.oidc_client_secret
  signing_algorithms   = ["RS256"]
  api_url_prefix       = var.boundary_addr
  is_primary_for_scope = true
  state                = "active-public"
}

resource "boundary_account_oidc" "oidc_user" {
  name           = var.oidc_username
  description    = "OIDC account for user1"
  auth_method_id = boundary_auth_method_oidc.provider.id
  issuer  = var.oidc_issuer
  subject = var.oidc_user_objectid
}