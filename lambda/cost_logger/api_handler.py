import os
import boto3
import json

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DDB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    response = table.scan()
    items = response.get('Items', [])
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(items)
    }
