variable "additional_vhosts" {
  type        = list
  default     = []
  description = "Additional virtual host to condifure in the CloudFront distribution."
}

variable "index_page" {
  default     = "index.html"
  description = "The object that you want CloudFront to return when an end user requests the root URL."
  type        = string
}

variable "error_page" {
  default     = "error.html"
  description = "The path of the custom error page."
  type        = string
}

variable "environment" {
  type        = string
  description = "Environment where is deployed."
}

variable "custom_tags" {
  description = "Custom tags to set on the resources"
  type        = map(string)
  default     = {}
}

# dns configuration
variable "root_zone" {
  type        = string
  description = "Name of the hosted zone."
}
variable "cname" {
  type        = string
  description = "CNAME for the website."
}
variable "eval_health_check" {
  type        = bool
  default     = false
  description = "Set to true if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set"
}

