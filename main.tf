provider "aws" {
  region = "us-east-1"
}

# AWS Key Pair
resource "aws_key_pair" "my_keypair" {
  key_name   = "your_keypair_name"  # You can change this according to your needs
  public_key = file("./.ssh.pub")  # Update with the path to your public key
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web_security_group"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update this with your desired SSH access

  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update this with your desired HTTP access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "my_instance" {
  ami             = "your_ami_id"  # Specify the AMI ID of your desired OS image
  instance_type   = "t2.micro"     # Change this as per your requirements
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "MonolithInstance"
  }
}

# EBS Volume
resource "aws_ebs_volume" "my_volume" {
  availability_zone = "${aws_instance.my_instance.availability_zone}"
  size              = 8  # Change the size as needed
  tags = {
    Name = "MonolithVolume"
  }
}

# Attach Volume to Instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.my_instance.id
}

# RDS Database
resource "aws_db_instance" "my_db" {
  engine            = "your_db_type"  # Specify your desired DB engine type
  instance_class    = "db.t2.micro"   # Change this as per your requirements
  allocated_storage = 20  # Change the allocated storage as needed
  #name              = "my_database"
  username          = "db_username"
  password          = "db_password"
}

# Additional Resources like PHP, Apache, Nginx can be added here as per requirement
