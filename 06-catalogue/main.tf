#Team ni form cheyali ...ante ... Target group create cheyali.....just for team creation

resource "aws_lb_target_group" "catalogue" {
  name     = "${local.name}-${var.tags.component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    healthy_threshold   = 2 #sucessful ga 2 two times vasteyy healthy
    interval            = 10 #interval
    unhealthy_threshold = 3
    timeout             = 5 #5seconds request rakkapotheyy timeout
    path                = "/health"
    port                = 8080
    matcher = "200-299"
  }
}

#instances ni create chestunam

module "catalogue" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.centos8.id
  name                   = "${local.name}-${var.tags.component}-ami"
  instance_type          = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]
  subnet_id              = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
  iam_instance_profile = "ShellScriptRoleForRoboshop"
  tags = merge(
    var.common_tags,
    var.tags,
  )
}

#provision chestnam

resource "null_resource" "catalogue" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.catalogue.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.catalogue.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue dev"
    ]
  }
}


#-----------------------------------------------------------------------------------

#Stop the instance

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = module.catalogue.id
  state       = "stopped"
  depends_on = [ null_resource.catalogue ] #Depends_on andhuku ante pina vuna instance create aye provision ina thruwatheyy instance annedi stop avvali ..so dhanikosame depends_on petam.so eppudu instance annedi stop avuthadi.
}

#---------------------------------------
#Take AMI from above instance --- google #type aws terraform AMI from instance

resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.name}-${var.tags.component}-${local.current_time}"
  source_instance_id = module.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue]
}

#------------------------------------------------------
#Delete the instance

resource "null_resource" "catalogue_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.catalogue.id
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    command = "aws ec2 terminate-instances --instance-ids ${module.catalogue.id}"
  }

  depends_on = [ aws_ami_from_instance.catalogue]
}


#Before that you must check the manually to create once------------------------------------
#launch template

resource "aws_launch_template" "catalogue" {
  name = "${local.name}-${var.tags.component}"

  image_id = aws_ami_from_instance.catalogue.id

  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  update_default_version = true 

  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-${var.tags.component}"  #roboshop-dev-catalogue
    }
  }
}

#----------------------------------------------------------------------------------------

#Autoscaling
resource "aws_autoscaling_group" "catalogue" {
  name                      = "${local.name}-${var.tags.component}"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  target_group_arns = [ aws_lb_target_group.catalogue.arn ]

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version #autoscaling annedi launch template lo vunde latest version ni consider chestadi.
  }

  instance_refresh {
    strategy = "Rolling" #RollingUpdate means 4 instances are there now, 4 new instances should be created and replace old
                          #1.new instance ----> once it is up, 1 old instance will be terminated.
                          #2.new instance ----> once it is up 2nd old instance will be terminated.So adhee instance refresh anteee.
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"] # triggers emi trigger cheyali ante lanuch_template ...lanuch template eppudaintheyy update avuthundo appudu autoscaling annedi automatic ga trigger ayye instance refresh avuthayee.That is the meaning
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-${var.tags.component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}


#----------------------------------------
#load balancer rule

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
   #listerner ki catalogue lo manam velli oka rule create chestanam. 
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["${var.tags.component}.app-${var.environment}.${var.zone_name}"]
    }

  }
}

#---------------------------------------------------------
#Autoscaling policy
resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = "${local.name}-${var.tags.component}"
  name                   = "${local.name}-${var.tags.component}"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}