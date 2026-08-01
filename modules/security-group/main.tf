resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Public ALB security group"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "application" {
  name        = "${var.name_prefix}-application-sg"
  description = "Private application instances"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-application-sg"
  })
}

resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-database-sg"
  description = "Private database"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-database-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  description = "HTTP from internet"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id = aws_security_group.alb.id

  description                  = "Application traffic"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = aws_security_group.application.id
}

resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id = aws_security_group.application.id

  description                  = "Application traffic from ALB"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "application_https" {
  security_group_id = aws_security_group.application.id

  description = "HTTPS outbound"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "application_http" {
  security_group_id = aws_security_group.application.id

  description = "HTTP package repositories"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "application_to_database" {
  security_group_id = aws_security_group.application.id

  description                  = "PostgreSQL to RDS"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.database.id
}

resource "aws_vpc_security_group_ingress_rule" "database_from_application" {
  security_group_id = aws_security_group.database.id

  description                  = "PostgreSQL from application"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.application.id
}