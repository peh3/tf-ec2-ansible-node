terraform {
  backend "s3" {
    bucket = "tk-tf-s3-bucket"
    key    = "tk-tf.tfstate"
    use_lockfile = true
    region = "us-east-1"
  }
}

