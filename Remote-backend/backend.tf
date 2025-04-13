terraform {
  backend "s3" {
    bucket = "keerthi4298"
    key    = "keerthi/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_endpoint = "terraform_lock"
  }
}
