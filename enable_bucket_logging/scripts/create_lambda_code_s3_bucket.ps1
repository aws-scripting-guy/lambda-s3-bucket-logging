# Define your lambda code bucket

Param(
  [string]$BUCKET = "my-very-own-bucket"
)

#$BUCKET = "my-very-own-bucket"

# Create S3 bucket for storing lambda code (default region of US standard is used)
aws s3 mb s3://$BUCKET

# Inside /functions directory Lambda function lambda-enable_bucket_logging.py is zipped into lambda.zip
# Any case you need to update lambda function code, create new zip file called lambda.zip

# Copy lambda function code to S3 bucket
aws s3 cp $PWD/functions/lambda.zip s3://$BUCKET/lambda.zip

