locals {
  vpc_name               = "ark-vpc"
  subnet_name             = "ark-subnet"
  vpc_cidr_block         = "10.0.0.0/22"
  public_subnet_cidr     = "10.0.1.0/24"
  private_a_subnet_cidr  = "10.0.2.0/24"
  private_b_subnet_cidr  = "10.0.3.0/24"

  public_subnet_az       = "us-east-1a"
  private_a_subnet_az    = "us-east-1a"
  private_b_subnet_az    = "us-east-1b"

  alb_sg_name            = "alb-sg"
  alb_sg_description     = "Allow HTTP and HTTPS"
  alb_name               = "app-alb"
}