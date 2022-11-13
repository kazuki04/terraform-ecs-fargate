terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  alb_origin_id = "ALBOrigin"

  default_cache_behavior = {
    target_origin_id            = local.alb_origin_id
    viewer_protocol_policy      = "allow-all"
    allowed_methods             = ["POST", "HEAD", "PATCH", "DELETE", "PUT", "GET", "OPTIONS"]
    cached_methods              = ["GET", "HEAD"]
    compress                    = false
    smooth_streaming            = false
    cache_policy_id             = aws_cloudfront_cache_policy.default.id
    origin_request_policy_id    = data.aws_cloudfront_origin_request_policy.managed_all_viewer.id
    response_headers_policy_id  = data.aws_cloudfront_response_headers_policy.managed_cors_and_securityheaders.id
    min_ttl                     = 0
    default_ttl                 = 0
    max_ttl                     = 0
    query_string                = true
    query_string_cache_keys     = []
    headers                     = ["*"]
    cookies_forward             = "none"
    cookies_whitelisted_names   = null
    lambda_function_association = []
    function_association        = []
    use_forwarded_values        = true
    query_string                = true
    cookies_forward             = "all"
  }

  ordered_cache_behavior = {
    target_origin_id            = local.alb_origin_id
    path_pattern                = "/api/*"
    viewer_protocol_policy      = "allow-all"
    allowed_methods             = ["POST", "HEAD", "PATCH", "DELETE", "PUT", "GET", "OPTIONS"]
    cached_methods              = ["GET", "HEAD"]
    compress                    = false
    smooth_streaming            = false
    cache_policy_id             = aws_cloudfront_cache_policy.default.id
    origin_request_policy_id    = data.aws_cloudfront_origin_request_policy.managed_all_viewer.id
    response_headers_policy_id  = data.aws_cloudfront_response_headers_policy.managed_cors_and_securityheaders.id
    min_ttl                     = 0
    default_ttl                 = 0
    max_ttl                     = 0
    query_string                = true
    query_string_cache_keys     = []
    headers                     = ["*"]
    cookies_forward             = "none"
    cookies_whitelisted_names   = null
    lambda_function_association = []
    function_association        = []
    use_forwarded_values        = true
    query_string                = true
    cookies_forward             = "all"
  }

  origins = [
    {
      origin_id            = local.alb_origin_id,
      domain_name          = var.alb_origin_dns_name,
      connection_attempts  = 3,
      connection_timeout   = 10,
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3"]
      },
      custom_header = [
        {
          name  = var.cf_custom_header_name
          value = var.cf_custom_header_value
        }
      ]
    }
  ]
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_response_headers_policy" "managed_cors_and_securityheaders" {
  name = "Managed-CORS-and-SecurityHeadersPolicy"
}


resource "aws_cloudfront_distribution" "this" {
  comment             =  "${var.service_name}-${var.environment_identifier}-cloudfront-distribution"
  # default_root_object = var.default_root_object
  enabled             = var.cloudfront_enabled
  http_version        = var.http_version
  price_class         = var.price_class
  # web_acl_id          = var.web_acl_id
  tags = {
    Name = "${var.service_name}-${var.environment_identifier}-cloudfront-distribution"
  }

  logging_config {
    bucket          = var.cloudfron_bucket_domain_name
    prefix          = "${var.service_name}-${var.environment_identifier}"
    include_cookies = false
  }

  dynamic "origin" {
    for_each = local.origins

    content {
      domain_name         = lookup(origin.value, "domain_name")
      origin_id           = lookup(origin.value, "origin_id", origin.key)
      origin_path         = lookup(origin.value, "origin_path", "")
      connection_attempts = lookup(origin.value, "connection_attempts", null)
      connection_timeout  = lookup(origin.value, "connection_timeout", null)
      # origin_access_control_id = lookup(origin.value, "origin_access_control_id", null)

      dynamic "custom_origin_config" {
        for_each = length(lookup(origin.value, "custom_origin_config", "")) == 0 ? [] : [lookup(origin.value, "custom_origin_config", "")]

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_header", [])

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = [local.default_cache_behavior]
    iterator = i

    content {
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods  = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods   = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress         = lookup(i.value, "compress", null)
      smooth_streaming = lookup(i.value, "smooth_streaming", null)

      cache_policy_id            = lookup(i.value, "cache_policy_id", null)
      origin_request_policy_id   = lookup(i.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(i.value, "response_headers_policy_id", null)
      # realtime_log_config_arn    = lookup(i.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      # dynamic "forwarded_values" {
      #   for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

      #   content {
      #     query_string            = lookup(i.value, "query_string", false)
      #     query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
      #     headers                 = lookup(i.value, "headers", [])

      #     cookies {
      #       forward           = lookup(i.value, "cookies_forward", "none")
      #       whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
      #     }
      #   }
      # }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(i.value, "function_association", [])
        iterator = f

        content {
          event_type   = f.key
          function_arn = f.value.function_arn
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = [local.ordered_cache_behavior]
    iterator = i
    content {
      path_pattern           = i.value["path_pattern"]
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods  = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods   = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress         = lookup(i.value, "compress", null)
      smooth_streaming = lookup(i.value, "smooth_streaming", null)

      cache_policy_id            = lookup(i.value, "cache_policy_id", null)
      origin_request_policy_id   = lookup(i.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(i.value, "response_headers_policy_id", null)
      # realtime_log_config_arn    = lookup(i.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      # dynamic "forwarded_values" {
      #   for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

      #   content {
      #     query_string            = lookup(i.value, "query_string", false)
      #     query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
      #     headers                 = lookup(i.value, "headers", [])

      #     cookies {
      #       forward           = lookup(i.value, "cookies_forward", "none")
      #       whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
      #     }
      #   }
      # }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(i.value, "function_association", [])
        iterator = f

        content {
          event_type   = f.key
          function_arn = f.value.function_arn
        }
      }
    }
  }

  # dynamic "ordered_cache_behavior" {
  #   for_each = var.ordered_cache_behavior
  #   iterator = i

  #   content {
  #     path_pattern           = i.value["path_pattern"]
  #     target_origin_id       = i.value["target_origin_id"]
  #     viewer_protocol_policy = i.value["viewer_protocol_policy"]

  #     allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
  #     cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
  #     compress                  = lookup(i.value, "compress", null)
  #     field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
  #     smooth_streaming          = lookup(i.value, "smooth_streaming", null)
  #     trusted_signers           = lookup(i.value, "trusted_signers", null)
  #     trusted_key_groups        = lookup(i.value, "trusted_key_groups", null)

  #     cache_policy_id            = lookup(i.value, "cache_policy_id", null)
  #     origin_request_policy_id   = lookup(i.value, "origin_request_policy_id", null)
  #     response_headers_policy_id = lookup(i.value, "response_headers_policy_id", null)
  #     realtime_log_config_arn    = lookup(i.value, "realtime_log_config_arn", null)

  #     min_ttl     = lookup(i.value, "min_ttl", null)
  #     default_ttl = lookup(i.value, "default_ttl", null)
  #     max_ttl     = lookup(i.value, "max_ttl", null)

  #     dynamic "forwarded_values" {
  #       for_each = lookup(i.value, "use_forwarded_values", true) ? [true] : []

  #       content {
  #         query_string            = lookup(i.value, "query_string", false)
  #         query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
  #         headers                 = lookup(i.value, "headers", [])

  #         cookies {
  #           forward           = lookup(i.value, "cookies_forward", "none")
  #           whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
  #         }
  #       }
  #     }

  #     dynamic "lambda_function_association" {
  #       for_each = lookup(i.value, "lambda_function_association", [])
  #       iterator = l

  #       content {
  #         event_type   = l.key
  #         lambda_arn   = l.value.lambda_arn
  #         include_body = lookup(l.value, "include_body", null)
  #       }
  #     }

  #     dynamic "function_association" {
  #       for_each = lookup(i.value, "function_association", [])
  #       iterator = f

  #       content {
  #         event_type   = f.key
  #         function_arn = f.value.function_arn
  #       }
  #     }
  #   }
  # }

  viewer_certificate {
    acm_certificate_arn            = lookup(var.viewer_certificate, "acm_certificate_arn", null)
    cloudfront_default_certificate = lookup(var.viewer_certificate, "cloudfront_default_certificate", null)
    iam_certificate_id             = lookup(var.viewer_certificate, "iam_certificate_id", null)
  }

  # dynamic "custom_error_response" {
  #   for_each = var.custom_error_response

  #   content {
  #     error_code = custom_error_response.value["error_code"]

  #     response_code         = lookup(custom_error_response.value, "response_code", null)
  #     response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
  #     error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
  #   }
  # }

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = lookup(geo_restriction.value, "restriction_type", "none")
        locations        = lookup(geo_restriction.value, "locations", [])
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "default" {
  name        =  "${var.service_name}-${var.environment_identifier}-cachepolicy-default"
  comment     = "The default cache policy for ${var.service_name} in ${var.environment_identifier} environment"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
