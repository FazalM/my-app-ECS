resource "aws_elb" "my-elb" {
  name            = "my-elb"
  subnets         = data.terraform_remote_state.ci_pipeline.outputs.public_subnet_ids
  security_groups = [data.terraform_remote_state.ci_pipeline.outputs.elb_sg_id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:662348578823:certificate/c4cc625b-e4db-43b7-b76f-c4a25eb7b77f"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 500
  tags = {
    Name = "my-elb"
  }
}