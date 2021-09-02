provider "aws" {
  region = var.aws_region
}


resource "aws_iam_instance_profile" "gateway_profile" {
  name = "appgate_gw_autoscaling"
  role = aws_iam_role.gateway_role.name
  # tags = var.common_tags
}


resource "aws_iam_role" "gateway_role" {
  name               = "appgate_gateway_role"
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
  name        = "secret-policy"
  description = "A secret policy"
  # tags        = var.common_tags
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
  depends_on = [
    appgatesdp_policy.api_gw_user_policy
  ]
  template = file("${path.module}/userdata.tpl")
  vars = {
    site_id        = data.appgatesdp_site.default_site.id
    pem            = data.appgatesdp_certificate_authority.ca.certificate
    controller_dns = var.controller_dns
    aws_region     = var.aws_region
    aws_secret_arn = aws_secretsmanager_secret_version.appgate_api_password.arn
    api_username   = appgatesdp_local_user.gateway_api_user.name
  }
}


module "autoscaling" {
  depends_on = [
    data.template_file.user_data,
    aws_iam_instance_profile.gateway_profile
  ]
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  lc_name   = "appgate-tf-lc"
  use_lc    = true
  create_lc = true

  # Autoscaling group
  name            = "appgate-gateways"
  use_name_prefix = false
  # iam_instance_profile_arn  = aws_iam_instance_profile.gateway_profile.arn
  iam_instance_profile_name = aws_iam_instance_profile.gateway_profile.id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier = [
    var.controller_subnet
  ]
  security_groups             = var.controller_security_groups
  key_name                    = var.aws_key_pair_name != "" ? var.aws_key_pair_name : "appgate-demo-deployer-key"
  user_data_base64            = base64encode(data.template_file.user_data.rendered)
  associate_public_ip_address = true


  image_id          = var.appgate_ami != "" ? var.appgate_ami : data.aws_ami.appgate_ami.id
  instance_type     = "m4.large"
  ebs_optimized     = true
  enable_monitoring = true

  ebs_block_device = [
    {
      device_name           = "/dev/xvdb"
      volume_type           = "gp2"
      volume_size           = "20"
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


  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "appgate"
      propagate_at_launch = true
    },
  ]

  tags_as_map = var.common_tags
}
