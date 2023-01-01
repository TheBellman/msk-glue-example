# --------------------------------------------------------------------------------
# create an instance in a 'public' subnet
# --------------------------------------------------------------------------------
data "aws_ami" "dev" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [local.ami]
  }
}

resource "aws_instance" "dev" {
  ami                         = data.aws_ami.dev.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnet_id[0]
  vpc_security_group_ids      = [module.vpc.public_sg]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  depends_on                  = [module.vpc]

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_type = "gp2"
    volume_size = 128
  }

  tags        = { Name = "Dev host" }
  volume_tags = { Name = "Dev host" }

  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y epel
yum -y -q update
yum -y -q groupinstall "Development Tools" 
yum -y -q install java-11 git openssl-devel libffi-devel bzip2-devel wget

mkdir -p /opt/python3.9
wget -q https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz -P /opt/python3.9
cd /opt/python3.9/
tar xf Python-3.9.0.tgz && rm Python-3.9.0.tgz
cd Python-3.9.0
./configure --enable-optimizations
make altinstall


cd /home/ec2-user

wget -q https://archive.apache.org/dist/kafka/3.2.0/kafka_2.12-3.2.0.tgz
tar xzf kafka_2.12-3.2.0.tgz && rm kafka_2.12-3.2.0.tgz

echo "security.protocol=SSL" > /home/ec2-user/client.properties

git clone https://github.com/TheBellman/msk-glue-example.git

chown -R ec2-user:ec2-user /home/ec2-user
EOF
}