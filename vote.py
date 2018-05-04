import os
import json
import boto3

local_table_name = 'local-test-table'

if os.getenv('AWS_SAM_LOCAL'):
    print("USING LOCAL DYNAMO")
    dynamodb = boto3.resource('dynamodb', endpoint_url="http://host.docker.internal:8000")
    votes_table = dynamodb.Table(local_table_name)
else:
    print("USING REMOTE DYNAMO")
    dynamodb = boto3.resource('dynamodb')
    votes_table = dynamodb.Table(os.getenv('TABLE_NAME'))

## HANDLERS
def voteresults(event, context):
    print(event)
    resp = votes_table.scan()
    return {'body': json.dumps({item['id']: int(item['votes']) for item in resp['Items']})}

def vote(event, context):
    try:
        body = json.loads(event['body'])
    except:
        return {'statusCode': 400, 'body': 'malformed json input'}
    if 'vote' not in body:
        return {'statusCode': 400, 'body': 'missing vote in request body'}
    if body['vote'] not in ['spaces', 'tabs']:
        return {'statusCode': 400, 'body': 'vote value must be "spaces" or "tabs"'}

    resp = votes_table.update_item(
        Key={'id': body['vote']},
        UpdateExpression='ADD votes :incr',
        ExpressionAttributeValues={':incr': 1},
        ReturnValues='ALL_NEW'
    )

    return {'body': "{} now has {} votes".format(body['vote'], resp['Attributes']['votes'])}
