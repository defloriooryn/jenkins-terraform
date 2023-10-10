# Security Group Application Load Balancer
resource "aws_security_group" "sg-alb" {
  name        = "sg_alb"
  vpc_id      = aws_vpc.vpc_example.id
  description = "allow http and https"
  dynamic "ingress" {
    for_each = var.sg_alb_port
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group Instance
resource "aws_security_group" "sg-instance" {
  name        = "sg_ec2"
  vpc_id      = aws_vpc.vpc_example.id
  description = "allow http from sg-alb"
  dynamic "ingress" {
    for_each = var.sg_ec2_port
    iterator = port
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
      security_groups = [aws_security_group.sg-alb.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security Group RDS
resource "aws_security_group" "sg-rds" {
  name        = "sg_rds"
  vpc_id      = aws_vpc.vpc_example.id
  description = "allow port 3306 from sg-instance"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "launch_template" {
  name          = "template"
  image_id      = var.instance_template.ami
  instance_type = var.instance_template.type
  user_data = base64encode(file("${path.module}/script/nginx.sh"))
  
  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.sg-instance.id]
  }
}

resource "aws_autoscaling_group" "asg" {
  # availability_zones = var.asg.az
  desired_capacity    = var.asg.desired
  min_size            = var.asg.min
  max_size            = var.asg.max
  target_group_arns   = [aws_lb_target_group.tg_instance.arn]
  vpc_zone_identifier = values(aws_subnet.private)[*].id

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_lb" "alb" {
  name               = "external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-alb.id]

  dynamic "subnet_mapping" {
    for_each = aws_subnet.public
    content {
      subnet_id = subnet_mapping.value.id
    }
  }

}
resource "aws_lb_target_group" "tg_instance" {
  name     = "nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_example.id

  health_check {
    path    = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.tg_instance.id
    type             = "forward"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = var.db.allocated_storage
  db_name              = var.db.db_name
  db_subnet_group_name = aws_db_subnet_group.sg_db.name
  engine               = var.db.engine
  engine_version       = var.db.engine_version
  instance_class       = var.db.instance_class
  username             = var.db.username
  password             = var.db.password
  parameter_group_name = var.db.parameter_group_name
  skip_final_snapshot  = var.db.skip_final_snapshot
  availability_zone    = var.db.availability_zone
  multi_az             = var.db.multi_az
}