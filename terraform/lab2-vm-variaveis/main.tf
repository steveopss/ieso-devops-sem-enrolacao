## data serve para consultar na nuvem um recurso que já exista.
## na maioria do caso vamos usar um recurso que já existe, feito por alguem anteriormente,
## então é normal fazer o uso do data, usar uma rede que ja existe, um resource group e etc.
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "this" {
  name                = "devops-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_virtual_network" "this" {
  name                = "devops-vnet"
  addres_space        = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "devops-subnet"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azure_network_interface" "this" {
  name                = "devops-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_ip          = azurerm_public_ip.this.ip
  }
}