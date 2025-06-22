import boto3
import json
import xmltodict
import logging

# Setup logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

def handler(event, context):
    try:
        # Step 1: Extract bucket and key
        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        logger.info(f"Received event for bucket: {bucket}, key: {key}")

        # Step 2: Download the .fdx file
        response = s3.get_object(Bucket=bucket, Key=key)
        fdx_data = response['Body'].read()
        logger.info(f"Successfully retrieved file: {key}")

        # Step 3: Convert XML to JSON
        fdx_dict = xmltodict.parse(fdx_data)
        json_data = json.dumps(fdx_dict, indent=2)
        logger.info(f"Successfully converted XML to JSON for file: {key}")

        # Step 4: Save to the /json/ folder
        json_key = key.replace('fdx/', 'json/').replace('.fdx', '.json')
        s3.put_object(
            Bucket=bucket,
            Key=json_key,
            Body=json_data,
            ContentType='application/json'
        )
        logger.info(f"Successfully uploaded JSON to {json_key}")

        return {
            'statusCode': 200,
            'body': f'Successfully converted {key} to {json_key}'
        }

    except Exception as e:
        error_key = key if 'key' in locals() else 'unknown'
        logger.error(f"Error processing file {error_key}: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': f"Failed to process {error_key}: {str(e)}"
        }
