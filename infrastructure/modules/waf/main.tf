################################################################################
# AWS WAF that checks custom header for ALB
################################################################################
resource "aws_wafv2_web_acl" "checks_customheader_from_cf" {
  name = "${var.service_name}-${var.environment_identifier}-waf-block-direct-access-alb"
  description = "Block direct access to ALB."
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "block-direct-access-alb"
    priority = 1

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        positional_constraint = "EXACTLY"
        search_string         = var.cf_custom_header_value
        field_to_match {
          single_header {
            name = var.cf_custom_header_name
          } 
        }
        text_transformation {
          priority = 0
          type = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.service_name}-${var.environment_identifier}-waf-rule-metrics-check-custom-header"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.service_name}-${var.environment_identifier}-waf-metrics-check-custom-header"
    sampled_requests_enabled   = false
  }

  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-waf-block-direct-access-alb"
  }
}

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = var.ingress_alb_arn
  web_acl_arn  = aws_wafv2_web_acl.checks_customheader_from_cf.arn
}
