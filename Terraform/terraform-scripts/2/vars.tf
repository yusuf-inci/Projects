variable "REGION" {
  default = "us-east-2"
}

variable "ZONE1" {
  default = "us-east-2a"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-2 = "ami-0cd3c7f72edd5b06d"
    us-east-1 = "ami-0005e0cfe09cc9050"
  }
}