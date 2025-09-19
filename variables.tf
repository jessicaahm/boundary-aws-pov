#------------------------------------------------------------------------------
# AWS PROVIDER
#------------------------------------------------------------------------------
variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1, eu-west-2)."
  }
}
#------------------------------------------------------------------------------
# NETWORKING
#------------------------------------------------------------------------------
variable "target_subnet_id" {
  type        = string
  description = "ID of VPC where Boundary will be deployed."
}
variable "vpc_id" {
  type        = string
  description = "ID of VPC where Boundary will be deployed."
}
#------------------------------------------------------------------------------
# BOUNDARY
#------------------------------------------------------------------------------
variable "boundary_addr" {
  description = "The address of the Boundary server."
  type        = string
  default     = null
}

variable "global_auth_method_id" {
  description = "The ID of the Boundary authentication method to use."
  type        = string
  default     = null
}

variable "global_admin_login_name" {
  description = "The login name for the Boundary authentication method."
  type        = string
  default     = null
}

variable "global_admin_password" {
  description = "The password for the Boundary authentication method."
  type        = string
  default     = null
}

variable "org_name" {
  description = "The name of the Boundary organization."
  type        = string
  default     = "DEMO-ORG"
}

variable "tls_insecure" {
  description = "Whether to skip TLS verification for the Boundary provider."
  type        = bool
  default     = true
}
#------------------------------------------------------------------------------
# BOUNDARY OIDC
#------------------------------------------------------------------------------
variable "oidc_client_id" {
  description = "The client ID for the OIDC provider."
  type        = string
  default     = null
}

variable "oidc_client_secret" {
  description = "The client secret for the OIDC provider."
  type        = string
  default     = null
}

variable "oidc_issuer" {
  description = "The issuer URL for the OIDC provider."
  type        = string
  default     = null
}

variable "oidc_username" {
  description = "The username for the OIDC provider."
  type        = string
  default     = null
}

variable "oidc_user_objectid" {
  description = "The user object ID for the OIDC provider."
  type        = string
  default     = null
}