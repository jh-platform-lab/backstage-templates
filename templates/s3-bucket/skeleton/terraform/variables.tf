variable "name" {
  description = "Prefijo del bucket"
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

variable "noncurrent_days" {
  description = "Dias que se conservan las versiones antiguas"
  type        = number
  default     = 90
}

variable "force_destroy" {
  description = "Permite borrar el bucket con objetos"
  type        = bool
  default     = false
}
