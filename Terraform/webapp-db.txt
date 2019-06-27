terraform {
  backend          "azurerm"        {}
}

resource "azurerm_resource_group" "rgroup" {
  name     = "${var.resource-group-name}"
  location = "${var.location}"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "appserviceplan2606"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app-service" {
  name                = "${var.app-service-name}"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  app_service_plan_id = "${azurerm_app_service_plan.plan.id}"

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
    value = "Server=tcp:${azurerm_sql_server.sqldb.fully_qualified_domain_name} Database=${azurerm_sql_database.db.name};User ID=${azurerm_sql_server.sqldb.administrator_login};Password=${azurerm_sql_server.sqldb.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "sqldb" {
  name                         = "sqlserver2606"
  resource_group_name          = "${azurerm_resource_group.rgroup.name}"
  location                     = "${azurerm_resource_group.rgroup.location}"
  version                      = "12.0"
  administrator_login          = "ruslan"
  administrator_login_password = "Jfeqzvgq521"
}

resource "azurerm_sql_database" "db" {
  name                = "sqldb2606"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  location            = "${azurerm_resource_group.rgroup.location}"
  server_name         = "${azurerm_sql_server.sqldb.name}"
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"


  tags = {
    environment = "PullToMaster"
  }
}
