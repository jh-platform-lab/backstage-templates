variable "name" {
  description = "Nombre de la cola"
  type        = string
}

variable "owner" {
  description = "Equipo propietario"
  type        = string
}

variable "region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "visibility_timeout" {
  description = "Segundos de visibilidad de un mensaje en proceso"
  type        = number
  default     = 30
}

variable "max_receive_count" {
  description = "Intentos antes de enviar a la DLQ"
  type        = number
  default     = 5
}

variable "retention_days" {
  description = "Dias de retencion de la cola principal"
  type        = number
  default     = 4
}
