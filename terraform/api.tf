# Lambda function for API (reuse same zip)
resource "aws_lambda_function" "api_lambda" {
  function_name = "cwa_api_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "api_handler.lambda_handler"
  runtime       = "python3.10"
  filename      = "../lambda/cost_logger.zip"
  timeout       = 30

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.cost_logs.name
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "cost_api" {
  name        = "cwa_cost_api"
  description = "API to fetch cost logs from DynamoDB"
}

# API Gateway resource (root)
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  parent_id   = aws_api_gateway_rest_api.cost_api.root_resource_id
  path_part   = "logs"
}

# API Gateway method (GET)
resource "aws_api_gateway_method" "get_logs" {
  rest_api_id   = aws_api_gateway_rest_api.cost_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway integration with Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.get_logs.http_method
  integration_http_method = "POST"
  type                     = "AWS_PROXY"
  uri                      = aws_lambda_function.api_lambda.invoke_arn
}

# Give API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cost_api.execution_arn}/*/*"
}
