data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

################################################################################
# Security Group for ALB
################################################################################
resource "aws_security_group" "ingress_lb" {
  name        = "${var.service_name}-${var.environment_identifier}-sg-alb-ingress"
  description = "allow access from Internet"
  vpc_id      = data.aws_vpc.vpc.id

  ingress = [
    # {
    #   from_port        = 443
    #   to_port          = 443
    #   cidr_blocks      = [
    #     "0.0.0.0/0"
    #   ]
    #   description      = "HTTPS traffic from Internet"
    #   protocol         = "tcp"
    #   ipv6_cidr_blocks = []
    #   prefix_list_ids  = []
    #   security_groups  = []
    #   self             = false
    # },
    {
      from_port        = 80
      to_port          = 80
      cidr_blocks      = [
        "0.0.0.0/0"
      ]
      description      = "HTTP traffic from Internet"
      protocol         = "tcp"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      cidr_blocks      = [
        "0.0.0.0/0"
      ]
      description      = "Allow traffic to Internet"
      protocol         = "-1"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-sg-alb-ingress"
  }
}


################################################################################
# Security Group for CodeBuild
################################################################################
resource "aws_security_group" "codebuild" {
  name        = "${var.service_name}-${var.environment_identifier}-sg-codebuild"
  description = "The Security group for CodeBuild project"
  vpc_id      = data.aws_vpc.vpc.id

  egress = [
    {
      from_port        = 0
      to_port          = 0
      cidr_blocks      = [
        "0.0.0.0/0"
      ]
      description      = "Allow traffic to Internet"
      protocol         = "-1"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-sg-codebuild"
  }
}
