data "aws_instances" "bluein" {

  filter {
    name   = "tag:Name"
    values = ["app_server-${var.env}"]
  # values = ["app_server-test"]
  }
  depends_on = [var.aws_inst]
}