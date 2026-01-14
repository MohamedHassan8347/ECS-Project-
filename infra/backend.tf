terraform {
  backend "s3" {
    bucket         = "mh-ecs-project-tfstate"
    key            = "ecs/prod/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "ecs-project-terraform-locks"
    encrypt        = true
  }
}
