resource "aws_lambda_function" "cost_logger" {
  function_name = "cwa_cost_logger"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"
  filename      = "../lambda/cost_logger.zip"   # path to your zip
  timeout       = 30

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.cost_logs.name
    }
  }
}


# EventBridge Rule to trigger Lambda every 5 minutes
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "cwa_cost_logger_schedule"
  schedule_expression = "rate(5 minutes)"
}

# EventBridge Target — Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.cost_logger.arn
}

# Give EventBridge permission to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_logger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
