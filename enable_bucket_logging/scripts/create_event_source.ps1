# Create CloudWtacht Events Rule to trigger Lambda periodically
aws events put-rule --name srv-S3-log-buckets-lambda `
--schedule-expression "cron(0/5 * * * ? *)" `
--state ENABLED `
--description "Trigger to enable S3 loggging via Lambda"


# Enable Rule for Lambda function
aws events put-targets --rule srv-S3-log-buckets-lambda `
--targets "Id=Lambda,Arn=arn:aws:lambda:eu-west-1:208046276943:function:srv-S3-log-buckets-lambda-function-LambdaFunction-QO7XVXTLOAJY"

# {
    "FailedEntries": [], 
    "FailedEntryCount": 0
}
