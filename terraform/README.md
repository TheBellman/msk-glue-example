# Example
This example uses the VPC module to stand up a VPC with private and "public" subnets. It then:

 - creates a Provisioned MSK cluster in the private subnets;
 - creates an EC2 instance in a public subnet which can access the cluster;
 
The EC2 instance allows traffic incoming from anywhere on 80 and 443 (e.g. you could mount a web service there), plus 22 for SSH from nominated CIDR blocks.

The cluster is not directly accessible from outside the VPC. This is by design.

## Prerequisites
This module does make use of Terraform version constraints (see `versions.tf`) but can be summarised as:

 - Terraform 1.3.6 or above
 - Terraform AWS provider 4.48.0 or above
 - the target AWS region has a usable EC2 Key Pair

The example code broadly assumes AWS CLI 2.9.10 or better is available.

## Usage

First, create `terraform.tfvars` using `terraform.tfvars.template` as an example, e.g.:

```
aws_region     = "eu-west-2"
aws_profile    = "adm_rhook_cli"
aws_account_id = "829199347043"
vpc_cidr       = "172.21.0.0/16"
vpc_name       = "msk-glue"
key_pair_name  = "adm_rhook"
ssh_inbound    = ["188.211.160.179/32", "3.8.37.24/29"]
tags           = { Class = "Development" }
```

In this example we allow SSH from a particular client plus some additional CIDR blocks from AWS.  These additional blocks are needed to allow the use of [Instance Connect](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/) through the AWS console.

These CIDR blocks are available from AWS using a small tool I wrote (see https://github.com/TheBellman/cidrapi):

```
curl https://mqciw5p4x8.execute-api.eu-west-2.amazonaws.com/v1/cidr/eu-west-2/EC2_INSTANCE_CONNECT
```


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

bootstraps = "b-1.glueexample.d0h8ge.c4.kafka.eu-west-2.amazonaws.com:9094, ...
eip_public_address = "35.177.195.129"
instance_id = "i-0135dd236aec248b7"
instance_ip = "18.133.161.68"
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
vpc_arn = "arn:aws:ec2:eu-west-2:889199313043:vpc/vpc-0b585be76b15786b5"
zookeeper = "z-1.glueexample.d0h8ge.c4.kafka.eu-west-2.amazonaws.com:2181, ...
```

You can connect to the instance using [mssh](https://github.com/aws/aws-ec2-instance-connect-cli), e.g.

```shell
$ mssh -u adm_rhook_cli i-0135dd236aec248b7
```

or using SSH with the key pair you have provided:

```shell
$ ssh -i adm_rhook ec2-user@18.133.161.68 
```

Note as well that you can get files on and off that host using `scp`:

```shell
$ scp -i adm_rhook README.md ec2-user@18.133.161.68:README.md
```

### Using Kafka
Having created the environment and Kafka cluster, you can exercise the cluster using the inbuilt scripts. As part of the setup, the relevant version of Kafka has been installed in the `ec2-user` home directory for convenient access to the tools. The configuration of the cluster we've setup does not require any client authentication, but it _does_ use TLS for transport between clients and the cluster. This requires a client-side configuration:

```shell
$ cat client.properties
security.protocol=SSL
```


With that in hand, and a bootstrap server, we can list topics:

```shell
$ kafka_2.12-3.2.0/bin/kafka-topics.sh \
  --bootstrap-server b-1.glueexample.d0h8ge.c4.kafka.eu-west-2.amazonaws.com:9094 \
  --command-config client.properties \
  --list
```

Create a topic:

```shell
$ kafka_2.12-3.2.0/bin/kafka-topics.sh \
  --bootstrap-server b-1.glueexample.d0h8ge.c4.kafka.eu-west-2.amazonaws.com:9094 \
  --command-config client.properties \
  --create --replication-factor 3 --partitions 1 \
  --topic TestOne 
```

Consume from the topic:

```shell
$ kafka_2.12-3.2.0/bin/kafka-console-consumer.sh \
	--bootstrap-server b-1.glueexample.d0h8ge.c4.kafka.eu-west-2.amazonaws.com:9094 \
	--consumer.config client.properties \
	--topic TestOne
```

And produce to the topic:

```shell
$ kafka_2.12-3.2.0/bin/kafka-console-producer.sh \
	--bootstrap-server b-1.glueexample.d0h8ge.c4.kafka.eu-west-2.amazonaws.com:9094 \
	--producer.config client.properties \
	--topic TestOne
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
