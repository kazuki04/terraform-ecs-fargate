variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = ""
}

variable "cloudfront_enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "cloudfron_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  type        = string
  default     = ""
}


variable "viewer_certificate" {
  description = "The SSL configuration for this distribution (maximum one)."
  type        = map(string)
  default     = {}
}

variable "price_class" {
  description = " The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
  type        = string
  default     = ""
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http2."
  type        = string
  default     = ""
}

variable "alb_origin_dns_name" {
  description = "The DNS name of the load balancer."
  type        = string
  default     = ""
}

variable "geo_restriction" {
  description = "The restriction configuration for this distribution (geo_restrictions)"
  type        = any
  default     = {}
}

variable "cf_custom_header_name" {
  description = "The custom header name of CloudFront"
  type        = string
  default     = ""
}

variable "cf_custom_header_value" {
  description = "The custom header value of CloudFront"
  type        = string
  default     = ""
}
