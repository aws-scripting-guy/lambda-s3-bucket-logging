# Credentials and default region should be already set

# S3 logs are delivered only on regional level. 
# Therefore log bucket needs to be created for each region

# PowerShell

#$regions =  "eu-west-1"
#$lambda_role_arn = "arn:aws:iam::208046276943:role/srv-S3-log-buckets-lambda-role-LambdaRole-1LQWTZBW2LTXB"
#$lambda_code_bucket = "my-very-own-bucket"

Param(
  [array]$regions = @( "eu-west-1"),
  [string]$lambda_role_arn,
  [string]$lambda_code_bucket = "my-very-own-bucket"
)

foreach ($region in $regions) {
    
    aws cloudformation create-stack `
    --tags file://$PWD\templates\stack_tags.json `
    --stack-policy-body file://$PWD\templates\stack_policy.json `
    --template-body file://$PWD\templates\lambda_function.cform `
    --stack-name "srv-S3-log-buckets-lambda-function" `
    --region $region `
    --parameters "ParameterKey=LambdaCodeBucket,ParameterValue=$lambda_code_bucket,UsePreviousValue=false" "ParameterKey=LambdaRoleArn,ParameterValue=$lambda_role_arn,UsePreviousValue=false"

}

