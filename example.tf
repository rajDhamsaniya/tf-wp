provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "local_file" "key" {
    filename = "/home/raj_dhamsaniya/.ssh/newpair.pem"
}

resource "aws_security_group" "tfsg" {
  name = "tfsg"
  description = "Allow HTTP trafic"

  ingress{
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_key_pair" "newkeyvalue" {
#   key_name = "newpair"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCG2BdeTqva9eqNevXX/v6I+isbuOnI+qmQAO3DlXjVlxZhSaCcLORVlWU7b3t3FBQ+gQwefc9Cik/gj4W2wV5ggsucFaRBkAwdf8SCQwxyUrr491DEJiKMTfd18BC66mH/MtZivXksEcEvUEoWtwCBdRc4MaYrHMIkzJc/WosoGL9d0rG+Ik1dyHWcM3fS/7N5nE7WiTjv3RAglbicPAellZ6opjFD4ZDiRU/TuXRCdAGW/GlCy+tdcUQN4srXEcGQ+0lwnYsW7uTW09lLB/PWKpwF8Wysl9VmEWWmkImY4zOZIefObRwHWuH4SiMS9CtSLQpDw/ZhXeOUXQfGrq0J"
# }


resource "aws_instance" "example" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "newpair"
  security_groups = ["${aws_security_group.tfsg.name}"]

  provisioner "remote-exec"{
    
    connection{
      type = "ssh"
      user = "ubuntu"
      private_key = "${data.local_file.key.content}"
    }
    
    inline = [
      "sudo apt-get update",
      "git clone https://github.com/rajDhamsaniya/tf-wp.git",
      "cd tf-wp",
      "chmod +100 docker-install.sh",
      "sudo ./docker-install.sh",
      "sudo docker-compose up -d"
    ]
  }
}

# output "exp1" {
#   value = "${element(aws_instance.example,0)}"
# }


# output "example1" {
#   value = "${aws_instance.example.1.id}"
# }
