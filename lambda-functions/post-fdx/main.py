import boto3
import logging
import os
import json
import base64
from datetime import datetime
import cgi
from io import BytesIO

# Initialize S3 client
s3 = boto3.client('s3')

# Setup logger with INFO level
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables for bucket names
UPLOAD_BUCKET = os.environ['UPLOAD_BUCKET']
EVAL_BUCKET = os.environ['UPLOAD_BUCKET']  # Note: Both buckets point to same env var
UPLOAD_PREFIX = 'fdx/'  # Prefix folder for uploaded files in S3

def handler(event, context):
    """
    Main Lambda handler function.
    Routes based on HTTP method: POST -> handle_upload, GET -> handle_get_result.
    Returns 405 if method not allowed.
    """
    try:
        method = event['requestContext']['http']['method']

        if method == 'POST':
            return handle_upload(event)
        elif method == 'GET':
            return handle_get_result(event)
        else:
            return {
                "statusCode": 405,
                "body": json.dumps({"message": "Method Not Allowed"})
            }

    except Exception as e:
        logger.error(f"Error: {e}", exc_info=True)
        return {
            "statusCode": 500,
            "body": f"Internal server error: {str(e)}"
        }

def handle_upload(event):
    """
    Handles file upload via POST request.
    Decodes base64 if encoded, parses multipart form-data,
    validates .fdx extension, generates timestamped filename,
    and uploads file content to S3 under UPLOAD_PREFIX.
    Returns JSON with a jobId (filename).
    """
    # Decode the body, base64 or plain text
    if event.get("isBase64Encoded"):
        body_bytes = base64.b64decode(event["body"])
    else:
        body_bytes = event["body"].encode('utf-8')

    # Extract content-type header for multipart parsing
    content_type = event["headers"].get("content-type") or event["headers"].get("Content-Type")
    if not content_type:
        return {
            "statusCode": 400,
            "body": "Missing Content-Type header"
        }

    # Prepare environment and headers for cgi.FieldStorage to parse multipart form
    env = {'REQUEST_METHOD': 'POST'}
    headers = {'content-type': content_type}
    fs = cgi.FieldStorage(
        fp=BytesIO(body_bytes),
        environ=env,
        headers=headers
    )

    # Retrieve the uploaded file from form-data
    file_item = fs['file']
    filename = file_item.filename

    # Validate file extension is .fdx
    if not filename or not filename.endswith('.fdx'):
        return {
            "statusCode": 400,
            "body": "Uploaded file must have a .fdx extension"
        }

    # Create new filename with UTC timestamp appended for uniqueness
    timestamp = datetime.utcnow().strftime('%Y%m%dT%H%M%S')
    safe_name = filename.rsplit('.', 1)[0]
    new_filename = f"{safe_name}_{timestamp}.fdx"
    s3_key = f"{UPLOAD_PREFIX}{new_filename}"

    # Upload the file to S3 bucket
    s3.put_object(
        Bucket=UPLOAD_BUCKET,
        Key=s3_key,
        Body=file_item.file.read(),
        ContentType="application/xml"
    )

    logger.info(f"Uploaded {new_filename} to S3")

    # Return success with jobId referencing the uploaded file
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Upload successful",
            "jobId": new_filename
        })
    }

def handle_get_result(event):
    """
    Handles GET request to retrieve evaluation results from S3.
    Expects query parameter 'jobId', which corresponds to filename.
    Returns the JSON content of the evaluation or an error if not found.
    """
    job_id = event["queryStringParameters"].get("jobId")
    if not job_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Missing jobId query parameter"})
        }

    key = f"bedrock-evaluations/{job_id}"

    try:
        # Retrieve the evaluation result file from S3
        response = s3.get_object(Bucket=EVAL_BUCKET, Key=key)
        result_body = response["Body"].read().decode("utf-8")

        return {
            "statusCode": 200,
            "body": result_body,
            "headers": {
                "Content-Type": "application/json"
            }
        }
    except s3.exceptions.NoSuchKey:
        # Return 404 if the result file is not found
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "Result not found"})
        }
