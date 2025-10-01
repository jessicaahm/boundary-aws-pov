#------------------------------------------------------------------------------
# VAULT
#------------------------------------------------------------------------------
variable "vault_addr" {
  description = "The address of the Vault server."
  type        = string
  default     = "https://127.0.0.1:9200"
}

#------------------------------------------------------------------------------
# EKS
#------------------------------------------------------------------------------
variable "cluster_endpoint" {
  description = "The endpoint for your Kubernetes API server."
  type        = string
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

variable "org_id" {
  description = "The ID of the Boundary organization."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The ID of the Boundary project."
  type        = string
  default     = null
}


variable "tls_insecure" {
  description = "Whether to skip TLS verification for the Boundary provider."
  type        = bool
  default     = true
}


