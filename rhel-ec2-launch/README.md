### Launch a RHEL ec2 instance with terraform

This assumes you have [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started) and
[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed on your local system.

Also, this script requires a VPC and base domain. See [vpc-base-domain.md](./vpc-base-domain.md) for details. 
There is a sample [terraform file](./terraform/main.tf) and an example [terraform/terraform.tfvars](./terraform/example-vars) file.
Customize based on the AWS account details. The example assumes a user `ec2-user` is configured.
Many AWS AMIs have a default ec2-user configured.

Then:

```bash
cd terraform
cp example-vars terraform.tfvars # edit terraform.tfvars according to your AWS account
terraform init
terraform plan
terraform apply
```

#### Accessing the instance

```bash
ssh -i /path/to/private/ssh-key ec2-user@ip-address
```

#### Destroying instance and associated AWS resources

```bash
cd terraform
terraform destroy
```
