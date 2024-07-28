# The entire section creates a certificate, public zone, and validates the certificate using DNS method.




# Create a Route 53 hosted zone
# resource "aws_route53_zone" "citatech" {
#   name = "citatech.online"  
# }

# # calling the hosted zone
data "aws_route53_zone" "citatech" {
  name         = "citatech.online"
  private_zone = false
}

# Fetch the Route 53 hosted zone using the ID
# data "aws_route53_zone" "citatech" {
#   zone_id = aws_route53_zone.citatech.zone_id
# }

# Create the certificate using a wildcard for all the domains created in citatech.online
resource "aws_acm_certificate" "citatech" {
  domain_name       = "*.citatech.online"
  validation_method = "DNS"
}

# selecting validation method
resource "aws_route53_record" "citatech" {
  for_each = {
    for dvo in aws_acm_certificate.citatech.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.citatech.zone_id
}

# validate the certificate through DNS method
resource "aws_acm_certificate_validation" "citatech" {
  certificate_arn         = aws_acm_certificate.citatech.arn
  validation_record_fqdns = [for record in aws_route53_record.citatech : record.fqdn]
}

# create records for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.citatech.zone_id
  name    = "tooling.citatech.online"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}


# create records for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.citatech.zone_id
  name    = "wordpress.citatech.online"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}