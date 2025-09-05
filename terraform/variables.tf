variable "image_tag" {
  description = "Tag of the Docker image to use"
  type        = string
}


# variables.tf
variable "ecs_cluster" {
  description = "Name of the ECS Cluster"
  type        = string
}
