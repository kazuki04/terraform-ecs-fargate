locals {
  vpc_id = aws_vpc.this.id
  region = "ap-northeast-1"
}

data "aws_caller_identity" "current" {}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-vpc"
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-igw"
  }
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-eip-nat"
  }
}

resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.ingress[0].id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-natgw"
  }

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "ingress" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-rtb-ingress"
  }
}

resource "aws_route" "ingress_internet_gateway" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################################################################################
# App routes
################################################################################

resource "aws_route_table" "app" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-rtb-app"
  }
}

################################################################################
# Database routes
################################################################################

resource "aws_route_table" "db" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-rtb-db"
  }
}

################################################################################
# Egress routes
################################################################################

resource "aws_route_table" "egress" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-rtb-egress"
  }
}

################################################################################
# CodeBuild routes
################################################################################

resource "aws_route_table" "codebuild" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-rtb-codebuild"
  }
}

resource "aws_route" "codebuild_nat_gateway" {
  route_table_id         = aws_route_table.codebuild.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Management routes
################################################################################

resource "aws_route_table" "management" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-rtb-management"
  }
}

resource "aws_route" "management_internet_gateway" {
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Ingress subnet
################################################################################

resource "aws_subnet" "ingress" {
  count = length(var.ingress_subnets) > 0 ? length(var.ingress_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = element(concat(var.ingress_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
      "${var.service_name}-${var.environment_identifier}-subnet-ingress-%s",
      element(var.azs, count.index)
    )
  }
}

################################################################################
# App subnet
################################################################################

resource "aws_subnet" "app" {
  count = length(var.app_subnets) > 0 ? length(var.app_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.app_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
      "${var.service_name}-${var.environment_identifier}-subnet-app-%s",
      element(var.azs, count.index)
    )
  }
}

################################################################################
# Database subnet
################################################################################

resource "aws_subnet" "db" {
  count = length(var.db_subnets) > 0 ? length(var.db_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.db_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
      "${var.service_name}-${var.environment_identifier}-subnet-db-%s",
      element(var.azs, count.index)
    )
  }
}

################################################################################
# Egress subnet
################################################################################

resource "aws_subnet" "egress" {
  count = length(var.egress_subnets) > 0 ? length(var.egress_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.egress_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
    "${var.service_name}-${var.environment_identifier}-subnet-egress-%s",
    element(var.azs, count.index),
    )
  }
}

################################################################################
# CodeBuild subnet
################################################################################

resource "aws_subnet" "codebuild" {
  count = length(var.codebuild_subnets) > 0 ? length(var.codebuild_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = var.codebuild_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
    "${var.service_name}-${var.environment_identifier}-subnet-codebuild-%s",
    element(var.azs, count.index),
    )
  }
}

################################################################################
# Management subnet
################################################################################
resource "aws_subnet" "management" {
  count = length(var.management_subnets) > 0 ? length(var.management_subnets) : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = element(concat(var.management_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
      "${var.service_name}-${var.environment_identifier}-subnet-management-%s",
      element(var.azs, count.index)
    )
  }
}

################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "ingress" {
  count = length(var.ingress_subnets) > 0 ? length(var.ingress_subnets) : 0

  subnet_id      = element(aws_subnet.ingress[*].id, count.index)
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route_table_association" "app" {
  count = length(var.app_subnets) > 0 ? length(var.app_subnets) : 0

  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db" {
  count = length(var.db_subnets) > 0 ? length(var.db_subnets) : 0

  subnet_id      = element(aws_subnet.db[*].id, count.index)
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "egress" {
  count = length(var.egress_subnets) > 0 ? length(var.egress_subnets) : 0

  subnet_id      = element(aws_subnet.egress[*].id, count.index)
  route_table_id = aws_route_table.egress.id
}

resource "aws_route_table_association" "codebuild" {
  count = length(var.codebuild_subnets) > 0 ? length(var.codebuild_subnets) : 0

  subnet_id      = element(aws_subnet.codebuild[*].id, count.index)
  route_table_id = aws_route_table.codebuild.id
}

################################################################################
# VPC endpoint
################################################################################

resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.service_name}-${var.environment_identifier}-sg-vpc_endpoint"
  description = "security group for vpc endpoint"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "allow HTTPS traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"] # tfsec:ignore:aws-ec2-no-public-egress-sgr

    description      = "Allow traffic to Internet"
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-sg-vpce"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.vpc_endpoints)

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${local.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [ aws_subnet.egress[0].id ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  depends_on = [
    aws_vpc.this, aws_subnet.egress
  ]

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-vpce-${each.value}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${local.region}.s3"
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Effect   = "Allow"
        Action   = ["*"]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-vpce-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "codebuild_route" {
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.codebuild.id}"
}

resource "aws_vpc_endpoint_route_table_association" "app_route" {
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.app.id}"
}
