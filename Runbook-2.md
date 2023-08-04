## Adding a data drive for logs to the existing deployment

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

### Add data drive

Add another disk in `additional_disks []` in `module "instance_template"` in `./main.tf`
```
  additional_disks = [
    {
      disk_name    = "disk-0"
      device_name  = "disk-0"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = {}
    },
    {
      disk_name    = "newly-added-disk"
      device_name  = "disk-1"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = {}
    },
  ]
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
