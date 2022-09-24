<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_k8s"></a> [k8s](#requirement\_k8s) | 0.9.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_k8s"></a> [k8s](#provider\_k8s) | 0.9.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [k8s_manifest.application_crd](https://registry.terraform.io/providers/banzaicloud/k8s/0.9.1/docs/resources/manifest) | resource |
| [k8s_manifest.oidc_authservice](https://registry.terraform.io/providers/banzaicloud/k8s/0.9.1/docs/resources/manifest) | resource |
| [kubernetes_secret.oidc_authservice_parameters](https://registry.terraform.io/providers/hashicorp/kubernetes/2.11.0/docs/resources/secret) | resource |
| [kubernetes_service.authservice](https://registry.terraform.io/providers/hashicorp/kubernetes/2.11.0/docs/resources/service) | resource |
| [kubernetes_stateful_set.authservice](https://registry.terraform.io/providers/hashicorp/kubernetes/2.11.0/docs/resources/stateful_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authservice"></a> [authservice](#input\_authservice) | Auth service configuration, expecting : client\_secret, client\_id, auth\_url, issuer, redirect\_url, userid\_claim, scopes information | `map(any)` | n/a | yes |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | n/a | `any` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the authservice will be deployed | `string` | n/a | yes |
| <a name="input_userid_header"></a> [userid\_header](#input\_userid\_header) | Name of the header used to pass the user's id | `string` | `"userid"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_userid_header"></a> [userid\_header](#output\_userid\_header) | n/a |
<!-- END_TF_DOCS -->