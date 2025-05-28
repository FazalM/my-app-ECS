resource "aws_route53_zone" "superstar" {
  name = "superstareducation.co.uk"
}

resource "aws_route53_record" "app_alias" {
  zone_id = aws_route53_zone.superstar.zone_id
  name    = "app.superstareducation.co.uk"
  type    = "A"

  alias {
    name                   = aws_elb.my-elb.dns_name
    zone_id                = aws_elb.my-elb.zone_id
    evaluate_target_health = true
  }
}

output "route53_name_servers" {
  value = aws_route53_zone.superstar.name_servers
}
