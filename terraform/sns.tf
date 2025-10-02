# SNS Topic
resource "aws_sns_topic" "cost_alerts" {
  name = "cwa-cost-alerts"
}

# SNS Subscription — replace email with your email
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = "ukpainnachi995@gmail.com"  # <- put your email here
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "cwa-billing-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = 21600
  threshold           = 0.01   # very low to trigger easily
  alarm_description   = "Alarm when estimated charges exceed $0.01"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  # Only works in us-east-1 for billing metrics
  dimensions = {
    Currency = "USD"
  }
}
