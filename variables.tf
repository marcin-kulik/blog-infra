variable "project" {}

variable "credentials_file" {}


variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "europe-west2"
}


variable "target_size" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  default     = 2
}

variable "service_account" {
  default = null
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
}

variable "network_name" {
  description = "The name of the VPC network being created"
  default     = "blog-network"
}