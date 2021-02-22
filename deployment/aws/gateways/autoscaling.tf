provider "aws" {
  region = var.aws_region
}


resource "aws_iam_instance_profile" "gateway_profile" {
  name = "appgate_gw_autoscaling"
  role = aws_iam_role.gateway_role.name
}


resource "aws_iam_role" "gateway_role" {
  name               = "appgate_gateway_role2"
  tags               = var.common_tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "gateway_policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "${aws_secretsmanager_secret.appgate_api_credentials.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.gateway_role.name
  policy_arn = aws_iam_policy.gateway_policy.arn
}

data "template_file" "user_data" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    site_id        = data.appgate_site.default_site.id
    pem            = data.appgate_certificate_authority.ca.certificate
    controller_dns = var.controller_dns
    aws_region     = var.aws_region
    aws_secret_arn = aws_secretsmanager_secret_version.appgate_api_password.arn
    api_username   = appgate_local_user.gateway_api_user.name
  }
}

module "autoscaling" {
  source               = "terraform-aws-modules/autoscaling/aws"
  version              = "3.8.0"
  name                 = "appgate-gateway"
  create_lc            = true
  lc_name              = "appgate-tf-lc"
  iam_instance_profile = aws_iam_instance_profile.gateway_profile.id
  image_id             = var.appgate_ami != "" ? var.appgate_ami : data.aws_ami.appgate.id
  instance_type        = "m4.large"
  security_groups = [
    var.security_group != "" ? var.security_group : data.aws_security_group.appgate_security_group.id
  ]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  key_name                     = var.aws_key_pair_name != "" ? var.aws_key_pair_name : "appgate-demo-deployer-key"

  user_data_base64 = base64encode(data.template_file.user_data.rendered)

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "50"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name = "appgate-asg"
  vpc_zone_identifier = [
    var.subnet_id != "" ? var.subnet_id : data.aws_subnet.appgate_appliance_subnet.id
  ]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags_as_map = var.common_tags
}
