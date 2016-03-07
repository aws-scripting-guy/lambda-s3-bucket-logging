#AWS Lambda: Enable S3 bucket logging

**Purpose**
-----------

This project leverages various AWS technologies to deploy Compliance Micro-Service through AWS Lambda.
Goal is to have a service which will enforce S3 server access logging on each of the buckets and delivers to centralized location.

Following these steps, you will programmatically create necessary AWS components with continuously running Lambda service.

![AWS Lambda: Enable S3 bucket logging](https://raw.githubusercontent.com/aws-scripting-guy/lambda/master/enable_bucket_logging/.assets/AWS%20Lambda-Enable%20S3%20bucket%20logging.png)


**Prerequisities**
------------------

* aws cli 
* aws credentials with IAM, S3, Lambda, CloudWatch Events and CloudFormation access (use Administrator Managed policy if not sure)
* tested on Windows with PowerShell. Scripts can be easily converted to shell.

**Notes**
---------
Defaults:
* Log bucket name format```my-s3-log-bucket-ACCOUNT_ID-REGION```.
* Default region ```eu-west-1``` (Ireland)

Deployment scripts support additional regions. Please note that Lambda, CloudFormation and CloudWatch Events should be supported in the region. You can pass any of supported regions as parameter value:
```
./scripts/provision_log_buckets.ps1 us-east-1 my-s3-log-bucket
```

Suggested is to leave **my-s3-log-bucket** as a log bucket name for this release.

**Steps**
---------

* Configure your AWS credentials (key, secret)
```
aws configure
```

* Clone this repo
```
git clone ...
```

* Navigate to repo folder
```
cd enable_bucket_logging
```

* Deploy logging buckets
```
./scripts/provision_log_buckets.ps1 <region_name> my-s3-log-bucket
# Output
"arn:aws:cloudformation:eu-west-1:208046276943:stack/srv-S3-log-buckets/b90941e0-e279-11e5-9e
d5-50a68645aed2"
```

* Deploy lambda role
```
./scripts/deploy_lambda_role.ps1 <region_name>
# Output
{
    "StackId": "arn:aws:cloudformation:eu-west-1:208046276943:stack/srv-S3-log-bu
ckets-lambda-role/070e18c0-e27a-11e5-ae2e-50faeb5524d2"
}
```

* Get lambda role arn from stack output
```
aws cloudformation describe-stacks --stack-name <stack-arn> --query 'Stacks[*].Outputs[*].OutputValue'
# Output
[
    [
        "arn:aws:iam::208046276943:role/srv-S3-log-buckets-lambda-role-LambdaRol
e-1LQWTZBW2LTXB"
    ]
]
```

* Create S3 bucket for storing lambda code
```
./scripts/create_lambda_code_s3_bucket.ps1 <new_bucket_name>
# Output
make_bucket: s3://my-very-own-bucket/
upload: functions\lambda.zip to s3://my-very-own-bucket/lambda.zip
```

* Deploy lambda function
```
./scripts/deploy_lambda_function.ps1 <region_name> <lambda_role_arn> <lambda_code_bucket>
# Output
{
    "StackId": "arn:aws:cloudformation:eu-west-1:208046276943:stack/srv-S3-log-b
uckets-lambda-function/1caefbc0-e27c-11e5-a4a0-50a6863404d2"
}
```

* Get Lambda role arn from stack output
```
aws cloudformation describe-stacks --stack-name <stack-arn> --query 'Stacks[*].Outputs[*].OutputValue'
# Output
[
    [
        "arn:aws:lambda:eu-west-1:208046276943:function:srv-S3-log-buckets-lambd
a-function-LambdaFunction-QO7XVXTLOAJY"
    ]
]
```

* Create sample S3 bucket
```
aws s3 mb s3://<bucket-for-lambda-test>
# Output
make_bucket: s3://lambda-test-orion/
```

* Check bucket logging on S3 sample bucket 
```
aws s3api get-bucket-logging --bucket <bucket-for-lambda-test>
# Null
```

* Invoke lambda function to setup S3 bucket logging
```
aws lambda invoke --function-name <function-arn> outputfile.txt
# Output
{
    "StatusCode": 200
}
```

* Verify bucket logging on S3 sample bucket 
```
aws s3api get-bucket-logging --bucket <bucket-for-lambda-test>
# Output
{
    "LoggingEnabled": {
        "TargetPrefix": "logs/lambda-test-orion/", 
        "TargetBucket": "my-s3-log-bucket-208046276943-eu-west-1"
    }
}
```

* Setup scheduled event for Lambda function so bucket logging is enforced on regular basis
```
 aws events put-rule --name srv-S3-log-buckets-lambda `
--schedule-expression "cron(0/5 * * * ? *)" `
--state ENABLED `
--description "Trigger to enable S3 logging via Lambda"
# Output
{
    "RuleArn": "arn:aws:events:eu-west-1:208046276943:rule/srv-S3-log-buckets-lambda"
}
```

* Enable scheduled event for Lambda function
```
aws events put-targets --rule srv-S3-log-buckets-lambda `
--targets "Id=Lambda,Arn=<lambda-function-arn>"
# Output
{
    "FailedEntries": [], 
    "FailedEntryCount": 0
}
```

* Create new sample bucket and after a while check logging settings
```
aws s3 mb s3://<new-bucket-for-lambda-test>
# After few minutes
aws s3api get-bucket-logging --bucket <new-bucket-for-lambda-test>
```

**Backlog**
------------------
* sns topic for notification when logging was not set (for ex. bucket policy blocking access)
* move deployment of lambda event source to additional script
* CloudFormation support for CloudWatch Events is not available yet, should move to template
* Lambda role has Administrator access (*). Should be limited to least privilege needed.
* Prevent unauthorized access to all resources (CloudFormation stacks, ...)
* Cleanup of all resources, if tested on separate Account