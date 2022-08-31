//PRimary Resourse for EC2 VM. Using RedHat 8.6 AMI (HVM-EBS) - Kernel 5.10, SSD Volume Type
// t2.micro 0.0162 per hour. 1V/1G
resource "aws_instance" "iac01" {

  ami                    = "ami-06640050dc3f556bb"
  instance_type          = "t2.micro"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name         = "IAC01"
    POC          = "Chet Camlin"
    Environment  = "IAC"
    CreateMethod = "Terraform"
    OS           = "RedHat 8.6"
    Owner        = "Chet Camlin"
    Reason       = "IAC Server"
    Email        = "chester.camlin.ctr@socom.mil"
    Phone        = "813-716-4552 or 813-826-6670"
  }

  //Upload and execute script. Then test connection. 
  provisioner "remote-exec" {
    inline = [
      "touch loop.txt",
      "echo hello Chet. How is your day going chet >> loop.txt",
    ]
  }

  //test ssh connection.  Make sure your .PEM file is in the path stated
  //inn the Private_key argument below. fsdf
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/aws_key.pem")
    timeout     = "4m"
  }
}

//Create security Group
resource "aws_security_group" "main" {
  tags = {
    Name        = "IAC Security Group"
    Environment = "Dev"
    Purpose     = "IAC01"
    Type        = "Terraform"
    GroupTag    = "IAC01 EC2"
  }
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}


