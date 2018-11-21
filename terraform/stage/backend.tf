terraform {
  backend "gcs" {
    bucket = "rainman17-test"
    prefix = "terraform/stage"
  }
}
