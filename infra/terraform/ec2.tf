resource "aws_key_pair" "insta_key_pa" {
  key_name   = "insta_key"
  public_key = file("insta-terra-key.pub")
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "insta_sg" {
  name   = "insta_sg"
  vpc_id = aws_default_vpc.default.id
  tags = {
    Name = "insta_sg"
  }
}


resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.insta_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_shh" {
  security_group_id = aws_security_group.insta_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_jenkins" {
  security_group_id = aws_security_group.insta_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend" {
  security_group_id = aws_security_group.insta_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 4000
  to_port           = 4000
  ip_protocol       = "tcp"
}

resource "aws_eip" "insta_ip" {
  instance = aws_instance.insta_clone_ec2.id
}

resource "aws_instance" "insta_clone_ec2" {

  instance_type   = "t2.large"
  ami             = "ami-0360c520857e3138f"
  security_groups = [aws_security_group.insta_sg.name]
  key_name        = aws_key_pair.insta_key_pa.key_name

  tags = {
    Name = "insta_clone"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

resource "local_file" "ansible_inventory_file_creation" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<EOT
[ubuntu]
${aws_eip.insta_ip.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/insta-terra-key
EOT
}



output "elastic_ip" {
  value = aws_eip.insta_ip.public_ip
}


