terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "nizamzam"
    key     = "terraform.tfstate"
    encrypt = true
  }
}