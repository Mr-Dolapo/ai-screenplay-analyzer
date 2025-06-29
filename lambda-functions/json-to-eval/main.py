import boto3
import json
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
bedrock = boto3.client('bedrock-runtime')

# Claude 3 Sonnet model ID (Messages API required)
BEDROCK_MODEL_ID = 'anthropic.claude-3-sonnet-20240229-v1:0'

def handler(event, context):
    try:
        # Extract S3 bucket and key
        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        logger.info(f"Triggered by JSON file: {key} in bucket: {bucket}")

        # Get the JSON script content
        response = s3.get_object(Bucket=bucket, Key=key)
        json_data = json.loads(response['Body'].read().decode('utf-8'))

        # Construct the message content for Claude
        message_content = f"""Please evaluate the following film script based on:
• Plot structure and pacing
• Character development and motivations
• Dialogue and interactions
• Subplots and themes
• Originality and creativity

Here is the script data in JSON format:

{json.dumps(json_data, indent=2)}

Give a structured and professional evaluation. Respond in JSON format with each criterion as a key."""

        # Invoke Claude 3 Sonnet using Messages API
        bedrock_response = bedrock.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            contentType="application/json",
            accept="application/json",
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",  
                "messages": [
                    {
                        "role": "user",
                        "content": message_content
                    }
                ],
                "max_tokens": 1024,
                "temperature": 0.7
            })
        )

        # Parse response from Bedrock
        response_body = bedrock_response['body'].read()
        model_output = json.loads(response_body)

        # Safely extract and parse the JSON text from Claude's response
        raw_content = model_output.get("content", [])
        if isinstance(raw_content, list) and len(raw_content) > 0:
            text_response = raw_content[0].get("text", "{}")
            model_json = json.loads(text_response)
        else:
            raise ValueError("Claude returned empty or malformed content.")

        # Build S3 key for output
        result_key = key.replace('json/', 'bedrock-evaluations/')

        # Store the evaluation in S3
        result_body = json.dumps({
            "original_script_key": key,
            "evaluation": model_json
        }, indent=2)

        s3.put_object(
            Bucket=bucket,
            Key=result_key,
            Body=result_body,
            ContentType='application/json'
        )

        logger.info(f"Saved evaluation to {result_key}")

        return {
            'statusCode': 200,
            'body': f"Evaluation saved to {result_key}"
        }

    except Exception as e:
        logger.error(f"Error evaluating {key if 'key' in locals() else 'unknown'}: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': f"Failed to evaluate script: {str(e)}"
        }
