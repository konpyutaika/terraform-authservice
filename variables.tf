variable "userid_header" {
  type        = string
  description = "Name of the header used to pass the user's id"
  default     = "userid"
}

variable "namespace" {
  type        = string
  description = "Namespace where the authservice will be deployed"
}

variable "authservice" {
  type        = map(any)
  description = "Auth service configuration, expecting : client_secret, client_id, auth_url, issuer, redirect_url, userid_claim, scopes information"
}

variable "module_depends_on" {
  type    = any
  default = null
}