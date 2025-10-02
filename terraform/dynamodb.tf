resource "aws_dynamodb_table" "cost_logs" {
  name         = "cost-tracker-logs"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "CloudCostTracker"
  }
}
