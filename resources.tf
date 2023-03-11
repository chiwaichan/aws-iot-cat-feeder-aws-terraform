resource "random_id" "id" {
	  byte_length = 8
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "cat_feeder_function"
  description   = "Lambda function that gets triggered when the SeeedStudio AWS 1-click IoT button is pressed"
  handler       = "app.lambda_handler"
  runtime       = "python3.8"
  
  environment_variables = {
    IoTEndpoint = data.aws_iot_endpoint.iot_endpoint.endpoint_address,
    ThingName   = var.cat_feeder_thing_lambda_name,
    Topic       = var.cat_feeder_thing_lambda_action_topic_name
    CatFeederCA       = aws_secretsmanager_secret.ca.name
    CatFeederCertificatePEM       = aws_secretsmanager_secret.certificate_pem.name
    CatFeederPrivateKey       = aws_secretsmanager_secret.private_key.name
  }

  attach_policy_json     = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow"
        Action : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource : [aws_secretsmanager_secret_version.ca.arn, aws_secretsmanager_secret_version.private_key.arn, aws_secretsmanager_secret_version.certificate_pem.arn]
      }
    ]
  })

  source_path = "src/cat_feeder_function/thing"

  tags = {
    Name = "cat feeder function"
  }
}