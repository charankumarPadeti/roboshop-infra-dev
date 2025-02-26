module "vpn" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main" #google serach cheyy ....aws e
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for VPN"
  vpc_id = data.aws_vpc.default.id
  sg_name ="vpn"
  #sg_ingress-rules = var.mongodb_sg_ingress-rules
}


module "mongodb" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main" #google serach cheyy ....aws e
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for mongodb"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="mongodb"
  #sg_ingress-rules = var.mongodb_sg_ingress-rules
}

module "redis" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for redis"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="redis"
  
}

module "mysql" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for mysql"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="mysql"
}

module "rabbitmq" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for rabbitmq"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="rabbitmq"
}

module "user" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for user"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="user"
}

module "catalogue" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for catalogue"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="catalogue"
}

module "cart" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for cart"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="cart"
}

module "shipping" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for shipping"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="shipping"
  
}

module "payment" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for payment"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="payment"
}

module "web" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for web"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="web"
}

#Application load-balacer security group
module "app_alb" {
  source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for APP ALB"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name ="app-alb"
}

# module "database" {
#   source = "git::https://github.com/charankumarPadeti/terraform-aws-security-group.git?ref=main"
#   project_name = var.project_name
#   environment = var.environment
#   sg_description = "SG for database"
#   vpc_id = data.aws_ssm_parameter.vpc_id.value
#   sg_name ="database"
# }

#open VPN

resource "aws_security_group_rule" "vpn_home" {
    security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #ideally your home IP address , but its frequently changes
}

#App ALB should accept connection only from VPN , since it is internal
resource "aws_security_group_rule" "app_alb_vpn" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    security_group_id = module.app_alb.sg_id
}


resource "aws_security_group_rule" "mongodb_vpn" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = module.mongodb.sg_id
}


#mongodb is aceepting conncetions from catalogue instance
resource "aws_security_group_rule" "mongodb_catalogue" {
    source_security_group_id = module.catalogue.sg_id
    type              = "ingress"
    from_port         = 27017
    to_port           = 27017
    protocol          = "tcp"
    security_group_id = module.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_user" { #This mongodb is accepting connection from below source (user source) .
    source_security_group_id = module.user.sg_id    
    type              = "ingress"
    from_port         = 27017
    to_port           = 27017
    protocol          = "tcp"
    security_group_id = module.mongodb.sg_id #And we are adding into the mongodb
}

resource "aws_security_group_rule" "catalogue_app_alb" {
    source_security_group_id = module.app_alb.sg_id
    type              = "ingress"
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    security_group_id = module.catalogue.sg_id
}


resource "aws_security_group_rule" "redis_vpn" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = module.redis.sg_id
}


resource "aws_security_group_rule" "redis_cart" {
    source_security_group_id = module.cart.sg_id
    type              = "ingress"
    from_port         = 6379
    to_port           = 6379
    protocol          = "tcp"
    security_group_id = module.redis.sg_id
}


resource "aws_security_group_rule" "redis_user" {
    source_security_group_id = module.user.sg_id
    type              = "ingress"
    from_port         = 6379
    to_port           = 6379
    protocol          = "tcp"
    security_group_id = module.redis.sg_id
}

resource "aws_security_group_rule" "mysql_vpn" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "mysql_shipping" {
    source_security_group_id = module.shipping.sg_id
    type              = "ingress"
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "rabbitmq_vpn" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "rabbitmq_payment" {
    source_security_group_id = module.payment.sg_id
    type              = "ingress"
    from_port         = 5672
    to_port           = 5672
    protocol          = "tcp"
    security_group_id = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_hhtp" {
    source_security_group_id = module.vpn.sg_id
    type              = "ingress"
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    security_group_id = module.catalogue.sg_id
}