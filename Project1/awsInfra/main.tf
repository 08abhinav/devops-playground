data "aws_ami" "ubuntu"{
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source = "./network"
}

resource "aws_instance" "webserver1" {
  ami                   = data.aws_ami.ubuntu.id
  instance_type         = var.instance_type
  key_name              = var.keyPair

  vpc_security_group_ids = [
    module.network.security_group_id
  ]

  subnet_id         = module.network.subnet1_id
  user_data_base64  = base64encode(file("./data/prerequi.sh"))
  tags = {
    Name = "nginx-server"
  }
}

output "instance1_public_ip" {
  value = aws_instance.webserver1.public_ip
}