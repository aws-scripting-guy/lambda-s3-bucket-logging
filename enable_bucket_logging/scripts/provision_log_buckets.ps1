# Credentials and default region should be already set

# S3 logs are delivered only on regional level. 
# Therefore log bucket needs to be created for each region

# PowerShell
#$regions = "eu-west-1","us-east-1"

Param(
  [array]$regions = @( "eu-west-1"),
  [string]$log_bucket_name = "my-s3-log-bucket"
)

foreach ($region in $regions) {
    
    aws cloudformation create-stack `
    --parameters "ParameterKey=LogBucketName,ParameterValue=$log_bucket_name,UsePreviousValue=false" `
    --tags file://$PWD\templates\stack_tags.json `
    --stack-policy-body file://$PWD\templates\stack_policy.json `
    --template-body file://$PWD\templates\log_bucket.cform `
    --stack-name "srv-S3-log-buckets" `
    --region $region `
    --query 'StackId'

}