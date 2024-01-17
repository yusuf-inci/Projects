provider "aws" {
  region = "us-east-2"
  #   access_key = ""
  #   secret_key = ""	
}

resource "aws_instance" "intro" {
  ami                    = "ami-0cd3c7f72edd5b06d"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-2a"
  key_name               = "dove-key"
  vpc_security_group_ids = ["sg-0db99bd6b4dcf07e4"]
  tags = {
    Name    = "Dove-Instance"
    Project = "Dove"
  }
}