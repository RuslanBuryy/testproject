variable "resource-group-name" {
  default = "preprod-resource-group"
  description = "The prefix used for all resources in this example"
}

variable "app-service-name" {
  default = "preprod-app-service"
  description = "The name of the Web App"
}

variable "location" {
  default = "West Europe"
  description = "The Azure location where all resources in this example should be created"
}

variable "server_name" {
  default = "serverpreprod"
  description = "Name of the server. "
}

variable "database_name" {
  default = "dbpreprod"
  description = "Name on the initial database on the server. "
