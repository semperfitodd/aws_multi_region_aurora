data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

data "aws_availability_zones" "region_0" {}

data "aws_availability_zones" "region_1" {
  provider = aws.eu-west-1
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ec2_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_kms_key" "rds_0" {
  key_id = "alias/aws/rds"
}

data "aws_kms_key" "rds_1" {
  provider = aws.eu-west-1
  key_id   = "alias/aws/rds"
}