terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }

  backend "s3" {
    bucket = "terraform-state-vvv"
    key    = "global/s3/lab.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
}

resource "aws_s3_bucket" "b" {
  bucket = "xxxxxxxxxxxxxxxxxxxxx-renomeie"
  #force_destroy = true
  provider = aws.oregon
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
  provider = aws.oregon
}

resource "aws_s3_bucket" "z" {
  provider = aws.oregon
  bucket   = "xxxxxxxxxxxxxxxxxxxxx-tmp"
}

resource "aws_s3_bucket_acl" "example_z" {
  provider = aws.oregon
  bucket   = aws_s3_bucket.z.id
  acl      = "private"
}