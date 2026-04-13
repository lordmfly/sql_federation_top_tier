
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name = "trino-aks"
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = "trino"

  default_node_pool {
    name = "default"
    node_count = 2
    vm_size = "Standard_DS3_v2"
  }

  identity { type = "SystemAssigned" }
}
