# IAM role for application pods to access AWS services
# Uses IRSA (IAM Roles for Service Accounts) for secure, credential-free access

resource "aws_iam_role" "app_role" {
  name = "${var.cluster_name}-app-role"

  # Trust policy: allows pods with specific service account to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          # Trust our EKS cluster's OIDC provider
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            # Only allow the specific service account we created
            "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:default:hello-world-ml-sa"
            "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-app-role"
  }
}

# Permission policy: what this role can actually do
resource "aws_iam_role_policy" "bedrock_access" {
  name = "bedrock-access"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Allows calling Claude models
        Action = [
          "bedrock:InvokeModel",                    # Single request-response
          "bedrock:InvokeModelWithResponseStream"   # Streaming responses
        ]
        # Only Claude models, no other Bedrock models
        Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-*"
      }
    ]
  })
}

# Output the role ARN so we can use it in Kubernetes service account
output "app_role_arn" {
  description = "IAM role ARN for application pods"
  value       = aws_iam_role.app_role.arn
}
