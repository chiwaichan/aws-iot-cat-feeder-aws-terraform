resource "aws_iot_certificate" "cat_feeder_thing_lambda" {
  active = true
}

resource "aws_iot_certificate" "cat_feeder_thing_controller" {
  active = true
}

data "aws_caller_identity" "current" {}
data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}

resource "aws_iot_thing" "cat_feeder_thing_lambda" {
  name = var.cat_feeder_thing_lambda_name

  attributes = {
    thingType = "lambda"
  }
}

resource "aws_iot_policy" "cat_feeder_thing_lambda" {
  name = var.cat_feeder_thing_lambda_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:Connect",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:client/${var.cat_feeder_thing_lambda_name}"
      },
      {
        Action = [
          "iot:Publish",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topic/${var.cat_feeder_thing_lambda_action_topic_name}"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "cat_feeder_thing_lambda" {
  policy = aws_iot_policy.cat_feeder_thing_lambda.name
  target = aws_iot_certificate.cat_feeder_thing_lambda.arn
}

resource "aws_iot_thing_principal_attachment" "cat_feeder_thing_lambda" {
  principal = aws_iot_certificate.cat_feeder_thing_lambda.arn
  thing     = aws_iot_thing.cat_feeder_thing_lambda.name
}


resource "aws_iot_thing" "cat_feeder_thing_controller" {
  name = var.cat_feeder_thing_controller_name

  attributes = {
    thingType = "seeedstudio-xiao-esp32C3"
  }
}

resource "aws_iot_policy" "cat_feeder_thing_controller" {
  name = var.cat_feeder_thing_controller_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:Connect",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:client/${var.cat_feeder_thing_controller_name}"
      },
      {
        Action = [
          "iot:Subscribe",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topicfilter/${var.cat_feeder_thing_lambda_action_topic_name}"
      },
      {
        Action = [
          "iot:Receive",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topic/${var.cat_feeder_thing_lambda_action_topic_name}"
      },
      {
        Action = [
          "iot:Publish",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topic/${var.cat_feeder_thing_controller_states_topic_name}"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "cat_feeder_thing_controller" {
  policy = aws_iot_policy.cat_feeder_thing_controller.name
  target = aws_iot_certificate.cat_feeder_thing_controller.arn
}

resource "aws_iot_thing_principal_attachment" "cat_feeder_thing_controller" {
  principal = aws_iot_certificate.cat_feeder_thing_controller.arn
  thing     = aws_iot_thing.cat_feeder_thing_controller.name
}