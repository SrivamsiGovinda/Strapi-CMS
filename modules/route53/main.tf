resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "strapi" {
  for_each = {
    prod    = var.prod_alb_dns
    staging = var.staging_alb_dns
  }
  zone_id = aws_route53_zone.main.zone_id
  name    = each.key == "prod" ? "strapi.${var.domain_name}" : "staging-strapi.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}