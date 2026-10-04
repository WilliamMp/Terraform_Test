data "archive_file" "function" {
  type        = "zip"
  source_file = "${path.module}/src/handler.py"
  output_path = "${path.module}/function.zip"
}