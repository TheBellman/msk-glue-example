# Example
This example uses the VPC module to stand up a VPC with private and "public" subnets.

## Prerequisites
This module does make use of Terraform version constraints (see `versions.tf`) but can be summarised as:

 - Terraform 1.3.6 or above
 - Terraform AWS provider 4.48.0 or above

The example code broadly assumes AWS CLI 2.9.10 or better is available.

## Usage

First, create `terraform.tfvars` using `terraform.tfvars.template` as an example, e.g.:

```
aws_region     = "eu-west-1"
aws_profile    = "adm_rhook_cli"
aws_account_id = "889199313043"
vpc_cidr       = "172.21.0.0/16"
vpc_name       = "msk-glue"
ssh_inbound    = ["188.211.160.179/32"]
tags           = { Class = "Development" }
```

In this example we allow SSH from a particular client.

After creating `terraform.tfvars` you will need to update `backend.tf` - see the [Terraform Documentation](https://www.terraform.io/docs/backends/index.html) for more information - you can even remove `backend.tf` competely to keep the Terraform state locally.

Finally, you can apply the example code:

```
terraform init
terraform apply
```

On completion, some useful information should be provided. Note that it could take several minutes for everything to build.

```
Apply complete! Resources: 50 added, 0 changed, 0 destroyed.

Outputs:

eip_public_address = 18.134.115.144
private_subnet = [
  "172.21.96.0/19",
  "172.21.128.0/19",
  "172.21.160.0/19",
]
public_subnet = [
  "172.21.0.0/19",
  "172.21.32.0/19",
  "172.21.64.0/19",
]
vpc_arn = arn:aws:ec2:eu-west-2:889199313043:vpc/vpc-026dcbaa33a863014
vpc_id = vpc-026dcbaa33a863014
```

## License
Copyright 2022 Little Dog Digital

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
