## Deployment of the infrastructure to a region of choice

### Requirements
- the latest version of Terraform installed [Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- project id
- auth key for service account [Guide](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

### Set up

1. Replace value of `project` in `./terraform.tfvars` with project_id:
    ```
   project = "your-project-id"
   ```
2. After downloading Json key, place the file in a directory of you choice or the root of the project.
3. Replace a value of `credentials_file` in `./terraform.tfvars` with a full path to your Json key:
    ```
    credentials_file = "./your-key-file.json"
    ```

### Change region

Replace value of `default` in a `variable "region"` in `./variables.tf`
```
variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "region-of-choice"
}
```

### Implement change

Run
```
terraform plan
```
If completed successfully without errors, then run:
```
terraform apply
```

### Trouble shouting

```
rm -rf .terraform
terraform init
terraform plan
terraform apply
```
