resource "aws_iam_role" "server_iam_role" {
	name = "${var.server_name}_iam_role"

	# Terraform's "jsonencode" function converts a
	# Terraform expression result to valid JSON syntax. 
	assume_role_policy = jsonencode({
		Version 	= "2012-10-17"
		Statement 	= [
		{
			Action = "sts:AssumeRole" 
			Effect = "Allow" 
			Sid = "Statement01" 
			Principal = {
				# AWS = [ "arn:aws:sts::<aws_account_number>:assumed-role/Management-us-east-1/i-08ff8cf3d0c1b66b5" ]
				Service = "ec2.amazonaws.com"
			}
		},
		]

	})

	managed_policy_arns = [ aws_iam_policy.assume_role_policy.arn, aws_iam_policy.server_policy.arn ]

	tags = {
		Name = "${var.server_name}_iam_role"
	}
}

resource "aws_iam_policy" "assume_role_policy" {
	name = "${var.server_name}_assume_role_policy" 
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = [ "sts:AssumeRole" ] 
				Effect = "Allow"
				# Resource = [ "arn:aws:iam::<aws_account_number>:role/AWSAccountNumber1Role", "arn:aws:iam:<aws_account_number_2>:role/AWSAccountNumber2Role" ]
				Resource = "*"
			},
		]
	})
}

resource "aws_iam_policy" "server_policy" {
	name = "${var.server_name}_server_policy"
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = [ 
						"application-autoscaling:*", 
						"autoscaling:*",
						"backup-storage:*", 
						"backup:*",
						"cloudformation:*",
						"cloudfront:*",
						"cloudwatch:*",
						"codebuid:BatchGetBuilds",
						"codebuild:BatchGetProjects",
						"codebuild:CreateProject",
						"codebuild:DeleteProject",
						"codebuild:ListProjects", 
						"codebuild:StartBuild",
						"codebuild:UpdateProject", 
						"codedeploy:*",
						"codepipeline:*", 
						"ec2:*",
						"ecr:*",
						"ecs:*",
						"eks:*",
						"elasticache:*",
						"elasticfilesystem:*",
						"elasticloadbalancing:*", 
						"events:*",
						"kms:*",
						"lambda:AddPermission",
						"lambda:CreateFunction",
						"lambda:DeleteFunction",
						"lambda:EnableReplication*",
						"lambda:GetFunction",
						"lambda:GetFunctionConfiguration",
						"lambda:ListVersionsByFunction",
						"lambda:PublishVersion",
						"lambda:RemovePermission",
						"lambda:UpdateFunctionCode",
						"lambda:UpdateFunctionConfiguration",
						"lambda:InvokeFunction",
						"sqs:*",
						"apigateway:*",
						"lambda:*",
						"Logs:*",
						"opsworks:*",
						"s3:*",
						"sns:*",
						"ssm: *",
						"waf:*",
						"wafv2:*",
						"rds:*",
						"appsync:*",
						"secretsmanager:*",
						"DynamoDB:*"
					]
			Effect = "Allow"
			Resource = "*"
			},
		]
	})
}

resource "aws_iam_instance_profile" "server_instance_profile" {
	name = "${var.server_name}_instance_profile"
	role = aws_iam_role.server_iam_role.name
}
