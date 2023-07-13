terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.aks_rg_name
  location = var.location
}

resource "azurerm_resource_group" "prj1_rg" {
  name     = var.prj1_rg_name
  location = var.location
}

resource "azurerm_virtual_network" "prj1_vnet" {
  name                = var.prj1_vnet_name
  depends_on          = [azurerm_resource_group.prj1_rg]
  resource_group_name = azurerm_resource_group.prj1_rg.name
  location            = var.location
  address_space       = [var.prj1_address_space]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  depends_on           = [azurerm_resource_group.aks_rg, azurerm_virtual_network.prj1_vnet]
  resource_group_name  = azurerm_resource_group.prj1_rg.name
  virtual_network_name = azurerm_virtual_network.prj1_vnet.name
  address_prefixes     = [var.aks_subnet_prefix]
}


resource "azurerm_kubernetes_cluster" "prj1_aks" {
  name                = "prj1_aks"
  depends_on          = [azurerm_subnet.aks_subnet]
  location            = var.location
  dns_prefix          = "prj1aks"
  resource_group_name = azurerm_resource_group.aks_rg.name
  kubernetes_version  = "1.25.6"

  default_node_pool {
    name                  = "default"
    orchestrator_version  = "1.25.6"
    node_count            = 1
    vm_size               = "standard_b2s"
    type                  = "VirtualMachineScaleSets"
    max_pods              = 250
    os_disk_size_gb       = 50
    vnet_subnet_id        = azurerm_subnet.aks_subnet.id
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 3
    enable_node_public_ip = false
  }

  # Configuring AKS to use a system-assigned managed identity to access
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    network_plugin    = "azure"
    # if non-azure network policies
    # https://azure.microsoft.com/nl-nl/blog/integrating-azure-cni-and-calico-a-technical-deep-dive/
    network_policy     = "calico"
    dns_service_ip     = "10.10.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.10.0.0/16"
  }
  lifecycle {
    ignore_changes = [
      default_node_pool,
    ]
  }
}