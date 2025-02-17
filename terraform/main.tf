/*
##########################
# 1. Rol IAM para Lambda #
##########################
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

####################################
# 2. Lambda Function (Django WSGI) #
####################################
resource "aws_lambda_function" "django_lambda" {
  function_name = "myDjangoLambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  
  # Sube tu archivo ZIP (generado por build.sh)
  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  # (Opcional) Variables de entorno
  environment {
    variables = {
      DJANGO_SETTINGS_MODULE = "backend.settings"
      ALLOWED_HOSTS          = "*"
      # etc.
    }
  }
}

################################
# 3. API Gateway (HTTP API v2) #
################################
resource "aws_apigatewayv2_api" "http_api" {
  name          = "myDjangoApi"
  protocol_type = "HTTP"
}

######################################################
# 4. Integración API Gateway <---> Lambda (Backend)  #
######################################################
resource "aws_apigatewayv2_integration" "http_api_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.django_lambda.arn
  integration_method = "ANY"
  payload_format_version = "2.0"
}

########################################
# 5. Rutas (catch-all para Django)     #
########################################
resource "aws_apigatewayv2_route" "http_api_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"  # Para que *cualquier* ruta se envíe a Django
  target    = "integrations/${aws_apigatewayv2_integration.http_api_integration.id}"
}

######################
# 6. Deployment/Stage
######################
resource "aws_apigatewayv2_stage" "http_api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true
}

##################
# 7. Permisos de Lambda para ser invocado por API Gateway
##################
resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowAPIGwInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.django_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

# Output de la URL
output "http_api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
  description = "URL pública de la API"
}
*/