# Run each of the below commands to provision s3 and dynamodb table via aws cli
# Run lines individually on terminal or by running "sh create_remote_state.sh" command


# Set variables
BUCKET_NAME="auto-discovery-s3"
DYNAMODB_TABLE_NAME="discovery-db"
REGION="eu-west-3"

# Create S3 bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION

# Tag the S3 bucket
aws s3api put-bucket-tagging --bucket $BUCKET_NAME --tagging 'TagSet=[{Key=Name,Value=pet-auto-remote-tfstate}]'

# Create DynamoDB table
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10 \
    --region $REGION