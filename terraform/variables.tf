variable "code_identification" {
  description = "Code d'identification unique"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "Canada Central"
}

variable "app_tier" {
  description = "Tier de l'Azure App Service"
  type        = string
  default     = "S1"
}
