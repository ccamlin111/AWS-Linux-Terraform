//PRimary Resourse for EC2 VM. Using RedHat 8.6 AMI (HVM-EBS) - Kernel 5.10, SSD Volume Type
// t2.micro 0.0162 per hour. 1V/1G. Running local now.  
resource "aws_instance" "iac01" {

  ami                    = "ami-06640050dc3f556bb"
  instance_type          = "t2.micro"
  key_name               = "awskey001"
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name         = "IAC01"
    POC          = "Joe Snuffy"
    Environment  = "IAC"
    CreateMethod = "Terraform"
    OS           = "RedHat 8.6"
    Owner        = "Joe Snuffy Jr"
    Reason       = "IAC Server"
    Email        = "info@home127001.com"
    Phone        = "813-716-4552 or 813-826-6670"
  }

  //Upload and execute script. Then test connection by entering the public address
  //of this EC2 instance.  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo service apache2 start",
      "touch loop.txt",
      "echo hello AWS Guru. How is your day going >> loop.txt",
    ]
  }

  //test ssh connection.  Make sure your .PEM file is in the path stated
  //in the Private_key argument below. This TF script is run from a directory.
  //The pem is in a sud directory in that directory. 
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("ssh/awskey001.pem")
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
      description      = "ssh"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
    ,{
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = "https"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]
}
