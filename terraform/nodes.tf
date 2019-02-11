resource "aws_security_group" "demo-node" {
  name        = "terraform-tw-demo-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.demo.id}"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.workstation-external-cidr}"]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    
  }

  tags = "${
    map(
     "Name", "terraform-demo-node",
    )
  }"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  // public_key = "${tls_private_key.example.public_key_openssh}"
  //public_key = "${base64decode(var.ssh_public_key)}"
  public_key = "${file("/tmp/ssh_util/keypair.key.pub")}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  most_recent = true
  owners      = ["679593333241"] # Amazon
}

locals {
  demo-node-userdata = <<USERDATA

USERDATA
}

resource "aws_instance" "primary" {

  count             = 2
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name               = "${aws_key_pair.generated_key.key_name}" 
  vpc_security_group_ids = ["${aws_security_group.demo-node.id}"]
  subnet_id              = "${data.aws_subnet_ids.application_subnet.ids[count.index]}"
  availability_zone = "${data.aws_subnet.demo.*.availability_zone[count.index]}"
  associate_public_ip_address = "True"


  connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    private_key = "${file("/tmp/ssh_util/keypair.key")}"
    # The connection will use the local SSH agent for authentication.
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install openjdk-8-jre-headless",
      "sudo apt-get -y install software-properties-common",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-get -y update",
      "sudo apt-get -y install ansible",
      
    ]
  }

  # upload jar file
  provisioner "file" {
    source      = "../infra-problem/build/"
    destination = "/home/ubuntu/"
  }

  # upload inbox directory content
  provisioner "file" {
    source      = "run.yml"
    destination = "/home/ubuntu/run.yml"
  }

  # run jar
  provisioner "remote-exec" {
    inline = [

      "cd /home/ubuntu/",
      "nohup ansible-playbook run.yml &",
      "sleep 10"
     
    

      
    ]
  }

  tags = {
      Role = "frontend"
  }

}
