terraform {
  backend          "azurerm"        {}
}

resource "azurerm_resource_group" "int" {
  name     = "${var.resource-group-name}"
  location = "${var.location}"
}

resource "azurerm_app_service_plan" "int" {
  name                = "int-appserviceplan"
  location            = "${azurerm_resource_group.int.location}"
  resource_group_name = "${azurerm_resource_group.int.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "int" {
  name                = "${var.app-service-name}"
  location            = "${azurerm_resource_group.int.location}"
  resource_group_name = "${azurerm_resource_group.int.name}"
  app_service_plan_id = "${azurerm_app_service_plan.int.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.int.fully_qualified_domain_name} Database=${azurerm_sql_database.int.name};User ID=${azurerm_sql_server.int.administrator_login};Password=${azurerm_sql_server.int.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "int" {
  name                         = "${var.server_name}"
  resource_group_name          = "${azurerm_resource_group.int.name}"
  location                     = "${azurerm_resource_group.int.location}"
  version                      = "12.0"
  administrator_login          = "ruslan"
  administrator_login_password = "Devops2606"
}

resource "azurerm_sql_database" "int" {
  name                = "${var.database_name}"
  resource_group_name = "${azurerm_resource_group.int.name}"
  location            = "${azurerm_resource_group.int.location}"
  server_name         = "${azurerm_sql_server.int.name}"
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"

  tags = {
    environment = "Integration"
  }
}
