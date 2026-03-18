#====================================
# Route 53
#====================================
# Retrieve a Route 53 Hosted Zone for uinlp.org.ng

data "aws_route53_zone" "uinlp_org_ng" {
  name = "uinlp.org.ng"
}

# Create a Route 53 Record for annotate.uinlp.org.ng
resource "aws_route53_record" "annotate_uinlp_org_ng" {
  zone_id = data.aws_route53_zone.uinlp_org_ng.zone_id
  name    = "annotate"
  type    = "CNAME"
  ttl     = 300
  records = [
    "fe4c09cad747ba8f.vercel-dns-017.com"
  ]
}
