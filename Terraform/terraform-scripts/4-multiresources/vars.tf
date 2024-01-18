variable "REGION" {
  default = "us-east-2"
}

variable "ZONE1" {
  default = "us-east-2a"
}

variable "ZONE2" {
  default = "us-east-2b"
}

variable "ZONE3" {
  default = "us-east-2c"
}

variable "AMIS" {
  type = map(any)
  default = {
    # amazon linux 2023 us-east-2 = "ami-0cd3c7f72edd5b06d"
    us-east-2 = "ami-0c2f3d2ee24929520"
    us-east-1 = "ami-0005e0cfe09cc9050"
  }
}

variable "USER" {
  default = "ec2-user"
}

variable "PUB_KEY" {
  default = "dovekey.pub"
}

variable "PRIV_KEY" {
  default = "dovekey"
}