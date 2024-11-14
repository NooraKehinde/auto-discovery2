resource "aws_iam_policy" "vault_kms_policy" {
  name        = "vault-kms-access-policy"
  description = "Policy for vault instances to access KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Effect   = "Allow",
        Resource = ["${aws_kms_key.vault_kms.arn}"]
      }
    ]
  })

  tags = {
    Name = "ec2-kms-access-policy"
  }
}
resource "aws_iam_role" "vault_role" {
  name = "vault-kms-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-kms-access-role"
  }
}
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.vault_role.id
  policy_arn = aws_iam_policy.vault_kms_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3-attach" {
  role       = aws_iam_role.vault_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_instance_profile" "vault_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.vault_role.name
}

