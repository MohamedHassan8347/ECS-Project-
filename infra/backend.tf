terraform {
  backend "s3" {
    bucket         = "umami-tfstate-057773388128"
    key            = "umami/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "umami-terraform-locks"
    encrypt        = true
  }
}

