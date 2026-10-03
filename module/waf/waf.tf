resource "aws_wafv2_web_acl" "public_api" {
  name        = "${var.project_name}-public-api"
  description = "Protection for the public API"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSCommonRules"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-common-rules"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-public-api-waf"
    sampled_requests_enabled   = false
  }
}


resource "aws_wafv2_web_acl_association" "public_api" {
  resource_arn = var.public_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.public_api.arn
}