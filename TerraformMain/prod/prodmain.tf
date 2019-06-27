terraform {
  backend          "azurerm"        {}
}

resource "azurerm_resource_group" "prod" {
  name     = "${var.resource-group-name}"
  location = "${var.location}"
}

resource "azurerm_app_service_plan" "prod" {
  name                = "prod-aprodserviceplan"
  location            = "${azurerm_resource_group.prod.location}"
  resource_group_name = "${azurerm_resource_group.prod.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "prod" {
  name                = "${var.aprod-service-name}"
  location            = "${azurerm_resource_group.prod.location}"
  resource_group_name = "${azurerm_resource_group.prod.name}"
  aprod_service_plan_id = "${azurerm_aprod_service_plan.prod.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  aprod_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.prod.fully_qualified_domain_name} Database=${azurerm_sql_database.prod.name};User ID=${azurerm_sql_server.prod.administrator_login};Password=${azurerm_sql_server.prod.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "prod" {
  name                         = "${var.server_name}"
  resource_group_name          = "${azurerm_resource_group.prod.name}"
  location                     = "${azurerm_resource_group.prod.location}"
  version                      = "12.0"
  administrator_login          = "ruslan"
  administrator_login_password = "Devops2606"
}

resource "azurerm_sql_database" "prod" {
  name                = "${var.database_name}"
  resource_group_name = "${azurerm_resource_group.prod.name}"
  location            = "${azurerm_resource_group.prod.location}"
  server_name         = "${azurerm_sql_server.prod.name}"
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"

  tags = {
    environment = "prodaction"
  }
}
