data "terraform_remote_state" "ci_pipeline" {
  backend = "s3"
  config = {
    bucket         = "fm-my-unique-terraform-bucket-2025"
    key            = "CI/terraform.tfstate"
    region         = "us-east-1"
  }
}

//data "aws_elb" "ci_elb" {
  //name = data.terraform_remote_state.ci_pipeline.outputs.elb_name
//}
