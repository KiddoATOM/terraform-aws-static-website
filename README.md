# terraform-aws-static-website 

Terraform module to provision AWS Static Website. Static Wesite served by S3 bucket and CloudFront distribution. Include ACM certification createtion and validation.

## Terraform versions

Terraform 0.12 compatible.

## Usage

```hcl
module "ecs" {
  source = "terraform-aws-static-website/"

  environment     = "development"
  custom_tags     = {
    "Project" = "personal"
  }
  root_zone        = "santiago-zurletti.com.ar"
  cname           = "www"
}
``` 

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_vhosts | Additional virtual host to condifure in the CloudFront distribution | list | `[]` | no |
| index\_page | The object that you want CloudFront to return when an end user requests the root URL | string | `index.html` | no |
| error\_page | The path of the custom error page | string | `error.html` | no |
| environment | Environment where is deployed | string |  n/a | yes |
| custom\_tags | Custom tags to set on the resources | map | `{}` | no |
| root\_zone | Name of the hosted zone | string | n/a | yes |
| cname | CNAME for the website | string | n/a | yes |
| eval\_health\_check | Set to true if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| url_host | URL of the website |
| fdqn |  |
| cdn\_distribution\_id | CloudFront distribution ID |
| s3\_bucket | s3 bucket ID |


## Authors

Module managed by [Santiago Zurletti](https://github.com/KiddoATOM).

## License

Apache 2 Licensed. See LICENSE for full details.