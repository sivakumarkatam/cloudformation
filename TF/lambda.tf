provider "aws" {
  region = "ap-southeast-1"
}

  resource "aws_lambda_function" "lambda_with_vpc" {
#  count = "${var.attach_vpc_config && ! var.attach_dead_letter_config ? 1 : 0}"

  vpc_config {
    security_group_ids = ["${var.security_group_ids}"]
    subnet_ids         = [
      "${var.subnet_a}",
      "${var.subnet_b}"
    ]
  }

  # ----------------------------------------------------------------------------
  # IMPORTANT:
  # Everything below here should match the "lambda" resource.
  # ----------------------------------------------------------------------------

  function_name                  = "${var.function_name}"
  filename                       = "lambda_function_payload.zip"
  source_code_hash               = "${filebase64sha256("lambda_function_payload.zip")}"
  description                    = "${var.description}"
  role                           = "${var.aws_iam_role_lambda_arn}"
#  filename                       = "${var.filename}"
  handler                        = "${var.handler}"
  memory_size                    = "${var.memory_size}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  runtime                        = "${var.runtime}"
  timeout                        = "${var.timeout}"
  #publish                        = "${local.publish}"
  tags                           = "${var.tags}"
  #filename                       = "${lookup(data.external.built.result, "filename")}"
  #depends_on                     = ["null_resource.archive"]
  environment                    = ["${slice( list(var.environment), 0, length(var.environment) == 0 ? 0 : 1 )}"]
}
