# Run each of the below commands to destroy s3 and dynamodb table via aws cli
# Run lines individually on terminal or by running "sh delete_remote_state.sh" command


# Set variables
BUCKET_NAME="auto-discovery-s3"
DYNAMODB_TABLE_NAME="discovery-db"
REGION="eu-west-3"

# Delete all objects from the S3 bucket
aws s3 rm s3://$BUCKET_NAME --recursive

# Delete the S3 bucket
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION

# Delete DynamoDB table
aws dynamodb delete-table --table-name $DYNAMODB_TABLE_NAME --region $REGION