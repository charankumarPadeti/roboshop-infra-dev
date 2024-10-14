resource "aws_lb" "app_alb" {
  name               = "${local.name}-${var.tags.component}"#roboshop-dev-app-alb
  internal           = true
  load_balancer_type = "application"
  security_groups = [ data.aws_ssm_parameter.app_alb_sg_id.value ]
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  #enable_deletion_protection = true


  tags = merge(
    var.common_tags,
    var.tags
  )
}

resource "aws_lb_listener" "http" {       #alb listerner terraform -------#Listener add chestunam port no 80 paina
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hi, This response is from APP ALB"
      status_code  = "200"
    }
  }
}

#-------------------------------------------------------------------------------------


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [                #record create chestanam andhukuante appalb lo DNS name change avuthundhi so manam oka record chesestam.
    {
      name    = "*.app-${var.environment}"
      type    = "A"
      alias   = {
        name    = aws_lb.app_alb.dns_name
        zone_id = aws_lb.app_alb.zone_id
      }
    }
  ]
}