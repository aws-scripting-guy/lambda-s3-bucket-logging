import boto3

# Backlog
# * bucket policy to cover log buckets

# if running with user credentials or EC2 instance we can get account ID:
# Thanks to https://gist.github.com/gene1wood/6d4974b7503336d642c9 

# Issue: Lambda did not allow to call metadata URL

#ACCOUNT_ID = json.loads(urllib2.urlopen('http://169.254.169.254/latest/meta-data/iam/info/', 
#            None, 
#           1).read())['InstanceProfileArn'].split(':')[4]

client = boto3.client('s3')


def lambda_handler(event, context):

    bucket_list = client.list_buckets()['Buckets']

    for bucket in bucket_list:
        print bucket['Name']

    # Get Account Id from lambda function arn
    print "lambda arn: " + context.invoked_function_arn
    
    # Get Account ID from lambda function arn in the context
    ACCOUNT_ID = context.invoked_function_arn.split(":")[4]
    print "Account ID=" + ACCOUNT_ID
    
    for bucket in bucket_list:

        print "bucket=" + bucket['Name']

        # Get region for each bucket
        try:
            location = client.get_bucket_location(Bucket=bucket['Name'])
            
            region = ""
            
            # Regions names pairings. 
            # For us-east-1 S3 location is None.
            # For us-east-1 S3 location is EU. 
            if location['LocationConstraint'] == "EU":
                region = "eu-west-1"
            elif location['LocationConstraint'] == None:
                region = "us-east-1"
            else: 
                region = location['LocationConstraint']
            
            print "region=" + region
            
        except:
            print "[ERROR]Unable to get bucket location of bucket " + bucket['Name']

        # Logging bucket format
        logging_bucket = u"my-s3-log-bucket-" + ACCOUNT_ID + "-" + region
        target_prefix = "logs/" + bucket['Name'] + "/"

        print "logging bucket=" + logging_bucket
        print "target prefix=" + target_prefix

        # Check if logging bucket exists
        try:
            client.head_bucket(Bucket=logging_bucket)
            # Enable logging
            client.put_bucket_logging(
                Bucket=bucket['Name'],
                BucketLoggingStatus={
                    'LoggingEnabled': {
                        'TargetBucket': logging_bucket,
                        'TargetPrefix': target_prefix
                    }
                }
            )
            print "enabling bucket logging for bucket=" + bucket['Name']
        except:
            print "[NOT FOUND]logging bucket " + logging_bucket + " not found"