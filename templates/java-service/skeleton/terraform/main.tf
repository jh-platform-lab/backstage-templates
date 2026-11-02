data "aws_caller_identity" "current" {}

# El proveedor OIDC de GitHub lo crea una sola vez el bootstrap de la cuenta.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  deploy_lambda = var.service_type == "lambda" && var.image_uri != ""
  function_arn  = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.service_name}"
}

# ---------------------------------------------------------------- imagenes

resource "aws_ecr_repository" "this" {
  name                 = var.service_name
  image_tag_mutability = "IMMUTABLE" # cada despliegue usa el SHA del commit

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS" # llave administrada por AWS (aws/ecr), sin costo
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Conserva las ultimas 10 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

# ------------------------------------------------------- rol de CD (OIDC)

data "aws_iam_policy_document" "cd_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Solo este repositorio y solo desde el entorno protegido.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${var.github_environment}"]
    }
  }
}

resource "aws_iam_role" "cd" {
  name               = "${var.service_name}-cd"
  assume_role_policy = data.aws_iam_policy_document.cd_trust.json
}

data "aws_iam_policy_document" "cd" {
  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [aws_ecr_repository.this.arn]
  }

  statement {
    sid = "LambdaDeploy"
    actions = [
      "lambda:GetFunction",
      "lambda:UpdateFunctionCode",
    ]
    resources = [local.function_arn]
  }
}

resource "aws_iam_role_policy" "cd" {
  name   = "deploy"
  role   = aws_iam_role.cd.id
  policy = data.aws_iam_policy_document.cd.json
}

# ------------------------------------------------------------------ lambda

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  count = local.deploy_lambda ? 1 : 0

  name               = "${var.service_name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  count = local.deploy_lambda ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  #checkov:skip=CKV_AWS_338: retencion de 14 dias es suficiente para la demo
  #checkov:skip=CKV_AWS_158: cifrado con llave administrada por defecto

  count = local.deploy_lambda ? 1 : 0

  name              = "/aws/lambda/${var.service_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "this" {
  #checkov:skip=CKV_AWS_50: X-Ray queda como evolucion; la observabilidad la cubre New Relic
  #checkov:skip=CKV_AWS_116: sin DLQ, la funcion es sincrona (Function URL)
  #checkov:skip=CKV_AWS_117: sin VPC para evitar costo de NAT; no accede a recursos privados
  #checkov:skip=CKV_AWS_173: variables sin datos sensibles (la licencia va por SSM)
  #checkov:skip=CKV_AWS_272: firma de codigo no aplica a imagenes de contenedor
  #checkov:skip=CKV_AWS_115: la concurrencia reservada depende del limite de la cuenta

  count = local.deploy_lambda ? 1 : 0

  function_name = var.service_name
  role          = aws_iam_role.lambda[0].arn
  package_type  = "Image"
  image_uri     = var.image_uri
  memory_size   = var.memory_size
  timeout       = var.timeout

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_logs,
  ]

  lifecycle {
    # El CD actualiza el codigo con update-function-code; Terraform no revierte la imagen.
    ignore_changes = [image_uri]
  }
}

resource "aws_lambda_function_url" "this" {
  #checkov:skip=CKV_AWS_258: URL publica a proposito para la demo; en produccion, API Gateway con autorizador y WAF

  count = local.deploy_lambda ? 1 : 0

  function_name      = aws_lambda_function.this[0].function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "url_invoke_url" {
  #checkov:skip=CKV_AWS_301: acceso publico a proposito para la demo (ver aws_lambda_function_url)

  count = local.deploy_lambda ? 1 : 0

  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this[0].function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "url_invoke_function" {
  #checkov:skip=CKV_AWS_301: acceso publico a proposito para la demo (ver aws_lambda_function_url)

  count = local.deploy_lambda ? 1 : 0

  statement_id             = "FunctionURLAllowInvokeAction"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.this[0].function_name
  principal                = "*"
  invoked_via_function_url = true
}
