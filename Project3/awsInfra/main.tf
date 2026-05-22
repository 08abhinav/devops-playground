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

locals{
  servers = {
    server1 = {
      instance_type = var.instance_type
      subnet_id     = module.network.subnet1_id
      name          = "server1"
    }

    server2 = {
      instance_type = var.instance_type
      subnet_id     = module.network.subnet1_id
      name          = "server2"
    }

    server3 = {
      instance_type = var.instance_type
      subnet_id     = module.network.subnet1_id
      name          = "server3"
    }
  }
}

resource "aws_instance" "servers" {

  for_each = local.servers

  ami                   = data.aws_ami.ubuntu.id
  instance_type         = each.value.instance_type
  key_name              = var.keyPair

  vpc_security_group_ids = [
    module.network.security_group_id
  ]

  subnet_id         = each.value.subnet_id
  user_data_base64  = base64encode(file("./data/prerequi.sh"))
  tags = {
    Name = each.value.name
  }
}

output "public_ips" {
  value = {
    for server_name, instance in aws_instance.servers :
    server_name => instance.public_ip
  }
}