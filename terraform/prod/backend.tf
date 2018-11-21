terraform {
  backend "gcs" {
    bucket = "rainman17"
    prefix = "terraform/prod"
  }
}
