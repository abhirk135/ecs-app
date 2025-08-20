resource "aws_vpc" "ark_vpc" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Name = local.vpc_name
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.ark_vpc.id
  cidr_block              = local.public_a_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = local.public_a_subnet_az
  tags = {
    Name = "${local.subnet_name}-public-a"
  }
  depends_on = [aws_vpc.ark_vpc]
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.ark_vpc.id
  cidr_block              = local.public_b_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = local.public_b_subnet_az
  tags = {
    Name = "${local.subnet_name}-public-b"
  }
  depends_on = [aws_vpc.ark_vpc]
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.ark_vpc.id
  cidr_block        = local.private_a_subnet_cidr
  availability_zone = local.private_a_subnet_az
  tags = {
    Name = "${local.subnet_name}-private-a"
  }
  depends_on = [aws_vpc.ark_vpc]
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.ark_vpc.id
  cidr_block        = local.private_b_subnet_cidr
  availability_zone = local.private_b_subnet_az
  tags = {
    Name = "${local.subnet_name}-private-b"
  }
  depends_on = [aws_vpc.ark_vpc]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ark_vpc.id
  depends_on = [aws_vpc.ark_vpc]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ark_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
  depends_on = [aws_route_table.public, aws_subnet.public_a]
}
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
  depends_on = [aws_route_table.public, aws_subnet.public_b]
}

resource "aws_security_group" "alb" {
  name        = local.alb_sg_name
  description = local.alb_sg_description
  vpc_id      = aws_vpc.ark_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.ark_vpc]
}

resource "aws_lb" "app_alb" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
  depends_on         = [aws_security_group.alb, aws_subnet.public_a, aws_subnet.public_b]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ark_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  depends_on = [aws_lb.app_alb]
}

# resource "aws_acm_certificate" "app_cert" {
#   domain_name       = "your.domain.com"
#   validation_method = "DNS"
# }

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.app_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  depends_on = [aws_lb_target_group.app_tg]
}