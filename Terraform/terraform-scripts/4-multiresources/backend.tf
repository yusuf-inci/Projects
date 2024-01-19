terraform {
  backend "s3" {
    bucket = "terra55-state-dove"
    key    = "terraform/4-multiresources"
    region = "us-east-2"
  }
}