output "ecr_repository_url" {
  description = "Repositorio donde el CD publica la imagen."
  value       = aws_ecr_repository.this.repository_url
}

output "cd_role_arn" {
  description = "Rol que asume el workflow de CD (variable AWS_ROLE_ARN del repo)."
  value       = aws_iam_role.cd.arn
}

output "function_url" {
  description = "URL publica de la Lambda (vacio hasta que exista la funcion)."
  value       = try(aws_lambda_function_url.this[0].function_url, null)
}
