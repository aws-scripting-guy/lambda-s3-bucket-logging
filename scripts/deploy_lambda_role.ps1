# Credentials and default region should be already set

# S3 logs are delivered only on regional level. 
# Therefore log bucket needs to be created for each region

# PowerShell
#$regions = "eu-west-1","us-east-1"
Param(
  [array]$regions = @( "eu-west-1")
)

foreach ($region in $regions) {
    
    aws cloudformation create-stack `
    --tags file://$PWD\templates\stack_tags.json `
    --stack-policy-body file://$PWD\templates\stack_policy.json `
    --template-body file://$PWD\templates\lambda_role.cform `
    --stack-name "srv-S3-log-buckets-lambda-role" `
    --region $region `
    --capabilities CAPABILITY_IAM

}

