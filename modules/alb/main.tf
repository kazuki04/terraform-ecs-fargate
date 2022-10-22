data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_lb" "ingress" {
  name = "${var.service_name}-${var.environment_identifier}-alb-ingress"

  load_balancer_type = "application"
  internal           = false
  security_groups    = [ var.sg_ingress_lb_id ]
  subnets            = var.subnets

  idle_timeout    = 300
  enable_http2    = true
  ip_address_type = "ipv4"

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-alb-ingress"
  }
}

resource "aws_lb_target_group" "api" {
  name = "${var.service_name}-${var.environment_identifier}-tg-api"

  vpc_id               = data.aws_vpc.vpc.id
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    path                = "/healthcheck"
    protocol            = "HTTP"
    timeout             = 25
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-targetgroup-api"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "api_lb" {
  load_balancer_arn = aws_lb.ingress.arn
  # certificate_arn   = aws_acm_certificate.api_cert.arn
  port              = 80
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Bad Gateway"
      status_code  = "502"
    }
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.api_lb.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn

  }

  condition {
    path_pattern {
      values = [
        "/api/*"
      ]
    }
  }
}
