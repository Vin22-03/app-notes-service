resource "aws_ecs_cluster" "notes_cluster" {
  name = "notes-app-cluster"
}

terraform {
  backend "s3" {
    bucket = "vin-tfstate-bucket"
    key    = "state.tfstate"
    region = "us-east-1"
  }
}

