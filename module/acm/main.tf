#creating route53 hosted zone
data "aws_route53_zone" "pet-zone" {
  name         = var.domain
  private_zone = false
}

#creating A jenkins record
resource "aws_route53_record" "jenkins-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.jenkins-domain
  type    = "A"
  alias {
    name                   = var.jenkins-dns_name
    zone_id                = var.jenkins-zone_id
    evaluate_target_health = true
  }
}
#creating A sonar record
resource "aws_route53_record" "sonar-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.sonar-domain
  type    = "A"
  alias {
    name                   = var.sonar-dns_name
    zone_id                = var.sonar-zone_id
    evaluate_target_health = true
  }
}
#creating A nexus record
resource "aws_route53_record" "nexus-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.nexus-domain
  type    = "A"
  alias {
    name                   = var.nexus-dns_name
    zone_id                = var.nexus-zone_id
    evaluate_target_health = true
  }
}
#creating A nexus record
resource "aws_route53_record" "stage-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.stage-domain
  type    = "A"
  alias {
    name                   = var.stage-LB-dns_name
    zone_id                = var.stage-LB-zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "prod-record" {
  zone_id = data.aws_route53_zone.pet-zone.zone_id
  name    = var.prod-domain
  type    = "A"
  alias {
    name                   = var.prod-LB-dns_name
    zone_id                = var.prod-LB-zone_id
    evaluate_target_health = true
  }
}
