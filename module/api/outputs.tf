output "private_process_execution_arn" {
  description = "Execution ARN for POST /process in the private API stage."

  value = "${aws_api_gateway_rest_api.private.execution_arn}/${aws_api_gateway_stage.private.stage_name}/POST/process"
}

