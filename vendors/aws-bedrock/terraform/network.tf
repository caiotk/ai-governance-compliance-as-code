# ─────────────────────────────────────────────────────────────────────────────
# Interface VPC endpoints (PrivateLink) for Bedrock, with private DNS so the SDK's
# default endpoint names resolve to private addresses inside the VPC.
# Source: https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html
# ─────────────────────────────────────────────────────────────────────────────

# AIG-08
resource "aws_security_group" "bedrock_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name        = "${var.name_prefix}-bedrock-endpoints"
  description = "HTTPS from approved CIDRs to Bedrock interface endpoints"
  vpc_id      = var.vpc_id

  lifecycle {
    precondition {
      condition     = var.vpc_id != null && length(var.subnet_ids) > 0 && length(var.endpoint_allowed_cidrs) > 0
      error_message = "enable_vpc_endpoints needs vpc_id, subnet_ids and endpoint_allowed_cidrs."
    }
  }
}

# AIG-08
resource "aws_vpc_security_group_ingress_rule" "bedrock_endpoints_https" {
  for_each = var.enable_vpc_endpoints ? toset(var.endpoint_allowed_cidrs) : toset([])

  security_group_id = aws_security_group.bedrock_endpoints[0].id
  description       = "HTTPS to Bedrock endpoints"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = each.value
}

# AIG-08
resource "aws_vpc_endpoint" "bedrock" {
  for_each = var.enable_vpc_endpoints ? toset(var.vpc_endpoint_services) : toset([])

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.bedrock_endpoints[0].id]

  tags = {
    Name = "${var.name_prefix}-${each.value}"
  }
}
