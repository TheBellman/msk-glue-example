# msk-glue-example
Demonstration of using AWS MSK (Kafka) with AWS Glue as a schema repository

## Prerequisites
The terraform code does makes use of version constraints (see [versions.tf](terraform/versions.tf)) but can be summarised as:

 - Terraform 1.3.6 or above
 - Terraform AWS provider 4.48.0 or above

The example code broadly assumes AWS CLI 2.9.10 or better is available.

## Usage

### Create Test Environment
To begin with change directories into the [terraform](terraform) folder and follow the [README.me](terraform/README.md) there for instructions. Those instructions include notes on how to connect to the test instance from your desktop.

### Execute Python Tests
During configuration, the ec2 instance will have pulled this repository down from GitHub, so the Python example code is available, but will take a little bit of bootstrapping up. After connecting to the host, perform the following:

```shell
$ cd msk-glue-example/python
$ pip3.9 install virtualenv
$ virtualenv venv
$ . venv/bin/activate
(venv) $ python -m pip install --upgrade pip
(venv) $ pip install -r requirements.txt
(venv) $ pip install --editable .
```

Note that on subsequent executions you will only need to "activate" the virtual environment:

```shell
$ . venv/bin/activate
(venv) $ pykafka \
	--bootstrap-server b-1.glueexample.6jw3ty.c4.kafka.eu-west-2.amazonaws.com:9094 \
	produce --count=10000
(venv) $ deactivate
$
```

To consume messages, use one of the Kafka nodes reported during the Terraform creation:

```shell
(venv) $ pykafka \
	--bootstrap-server b-1.glueexample.6jw3ty.c4.kafka.eu-west-2.amazonaws.com:9094 \
	consume
```

and to produce messages

```shell
(venv) $ pykafka \
	--bootstrap-server b-1.glueexample.6jw3ty.c4.kafka.eu-west-2.amazonaws.com:9094 \
	produce --count=10000
```

*Note*: we have configured the Kafka cluster to allow automatic topic creation (see [terraform/main.tf](terraform/main.tf)) so we don't need to explicitly create topics for our testing.

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