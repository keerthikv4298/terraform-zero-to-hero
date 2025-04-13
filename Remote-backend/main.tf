provider "aws"{
    region = "ap-south-1"
}


resource "aws_instance" "instance1"{
    ami = "ami-0e35ddab05955cf57"
    count = 1
    instance_type = "t2.micro"
}

# resource "aws_s3_bucket" "s3_bucket"{
#     bucket = "keerthi4298"
# }

#dynamodb for terraform lock
#note once create the s3, and dynamodb please process backend mechanism
resource "aws_dynamodb_table" "terraform_lock"{
    name = "terraform-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }
}