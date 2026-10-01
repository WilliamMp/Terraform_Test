import json


def handler(event, context):
    return {
        "statusCode": 501,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Application logic is outside this infrastructure test."
        })
    }