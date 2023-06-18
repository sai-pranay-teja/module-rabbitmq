resource "aws_iam_instance_profile" "Full-access-profile" {
  name = "${var.env}-profile"
  role = aws_iam_role.full-access-role.name
}


resource "aws_iam_policy_attachment" "full-access-attachment" {
  name       = "${var.env}-attachment"
  roles      = [aws_iam_role.full-access-role.name]
  policy_arn = aws_iam_policy.full-access-policy.arn
}


resource "aws_iam_role" "full-access-role" {
  name = "${var.env}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "full-access-policy" {
  name        = "${var.env}-policy"
  path = "/"
  policy = jsonencode({
    
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            Resource: [for i in local.parameters : "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/{var.env}.${i}.*"]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ssm:DescribeParameters",
            "Resource": "*"
        }
    ]

  
  })
}

