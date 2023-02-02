//Create security Group to open the proper ingress ports  
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
  ,{//This is just to test the default page
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = "http"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    }
  ]

}


//Primary Resourse for EC2 VM. Using RedHat 8.6 AMI (HVM-EBS) - Kernel 5.10, SSD Volume Type
// t2.micro 0.0162 per hour. 1V/1G. Running local now.  
resource "aws_instance" "IAC-RH9-01" {

  ami                    = "ami-0176fddd9698c4c3a" //RedHat 9
  instance_type          = "t2.micro" //Free tier
  key_name               = "awskey001" //SSH key pair name created in AWS
  vpc_security_group_ids = [aws_security_group.main.id]
  
  //Various Tags
  tags = {
    Name         = "IAC-RH9-01"
    POC          = "Joe Snuffy"
    Environment  = "IAC"
    CreateMethod = "Terraform"
    OS           = "RedHat 9"
    Owner        = "Joe Snuffy Jr"
    Reason       = "IAC Test Server"
    Email        = "info@home127001.com"
    Phone        = "813-555-5555 or 813-666-6666"
  }

  //install apache web server. 
  //of this EC2 instance.  
  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y update",
      "sudo dnf -y install httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
  }

  //test ssh connection.  Make sure your .PEM file is in the path stated below
  //in the Private_key argument. This TF script is run from any directory.
  //The pem is in the default home/user/.ssh directory. 
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/awskey001.pem")
    timeout     = "4m"
  }
}


//Run Terraform output public_ip from the terminal whenever you need the Public IP information
output "public_ip" {
  value = "${aws_instance.IAC-RH9-01.public_ip}"
}

output "ssh_login" {
  value = "ssh -i ~/.ssh/awskey001.pem ec2-user@${aws_instance.IAC-RH9-01.public_ip}"
}