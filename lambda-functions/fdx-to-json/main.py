import json

def handler(event, context):
    print("Received event:")
    print(json.dumps(event, indent=2))
    return {
        'statusCode': 200,
        'body': 'Event logged successfully'
    }
