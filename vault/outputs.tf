output "token" {
    value       = kubernetes_token_request_v1.vault_sa_token.token
    sensitive   = true
}