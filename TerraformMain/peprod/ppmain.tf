terraform {
  backend          "azurerm"        {}
}

resource "azurerm_resource_group" "pp" {
  name     = "${var.resource-group-name}"
  location = "${var.location}"
}

resource "azurerm_app_service_plan" "pp" {
  name                = "pp-appserviceplan"
  location            = "${azurerm_resource_group.pp.location}"
  resource_group_name = "${azurerm_resource_group.pp.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "pp" {
  name                = "${var.app-service-name}"
  location            = "${azurerm_resource_group.pp.location}"
  resource_group_name = "${azurerm_resource_group.pp.name}"
  app_service_plan_id = "${azurerm_app_service_plan.pp.id}"

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
    value = "Server=tcp:${azurerm_sql_server.pp.fully_qualified_domain_name} Database=${azurerm_sql_database.pp.name};User ID=${azurerm_sql_server.pp.administrator_login};Password=${azurerm_sql_server.pp.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "pp" {
  name                         = "serverpp"
  resource_group_name          = "${azurerm_resource_group.pp.name}"
  location                     = "${azurerm_resource_group.pp.location}"
  version                      = "12.0"
  administrator_login          = "ruslan"
  administrator_login_password = "Devops2707"
}

resource "azurerm_sql_database" "pp" {
  name                = "${var.database_name}"
  resource_group_name = "${azurerm_resource_group.pp.name}"
  location            = "${azurerm_resource_group.pp.location}"
  server_name         = "${azurerm_sql_server.pp.name}"
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"

  tags = {
    environment = "preprod"
  }
}
