resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}_ec2_role"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}_ec2_role"

  assume_role_policy = data.aws_iam_policy_document.ec2_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_instance" "ubuntu" {
  ami                     = data.aws_ami.ubuntu.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = aws_iam_instance_profile.this.name
  instance_type           = "t3.small"
  monitoring              = true
  subnet_id               = module.vpc_0.private_subnets[0]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "required"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get upgrade -y
              sudo apt-get dist-upgrade -y
              sudo apt-get install mysql-client -y
              EOF

  tags        = merge(var.tags, { "Name" = "${var.environment}_ubuntu" })
  volume_tags = merge(var.tags, { "Name" = "${var.environment}_ubuntu_vol" })

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [user_data, ami]
  }
}