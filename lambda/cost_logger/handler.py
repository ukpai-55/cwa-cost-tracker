import os
import boto3
import time
from decimal import Decimal

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DDB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    now = int(time.time())
    item = {
        'id': f'cost#{now}',
        'timestamp': now,
        'estimated_cost_usd': Decimal('0.01')
    }
    table.put_item(Item=item)
    return {"statusCode": 200, "body": "Logged to DynamoDB"}
