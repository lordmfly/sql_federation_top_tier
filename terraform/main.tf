
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = "sql-fed-rg"
  location = "East US"
}

module "aks" {
  source = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}
