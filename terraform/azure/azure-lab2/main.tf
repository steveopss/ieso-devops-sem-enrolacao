## data serve para consultar na nuvem um recurso que já exista.
## na maioria do caso vamos usar um recurso que já existe, feito por alguem anteriormente,
## então é normal fazer o uso do data, usar uma rede que ja existe, um resource group e etc.
## PS: uso do THIS segue as boas práticas do guidebook de terraform, como são recursos unicos,
# o uso do this está em conformidade, caso tivesse mais de 1, do mesmo recurso, seriam nomeados diferentes.
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Criando Recursos de Rede

resource "azurerm_public_ip" "this" {
  name                = "devops-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_virtual_network" "this" {
  name                = "devops-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "devops-subnet"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "this" {
  name                = "devops-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# Criando VM
resource "azurerm_linux_virtual_machine" "this" {
  name                            = "devops-vm"
  resource_group_name             = data.azurerm_resource_group.this.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.this.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


# Criando o firewall
resource "azurerm_network_security_group" "this" {
  name                = "devops-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# vinculando os recursos
resource "azurerm_network_interface_security_group_association" "this" {
  # Aqui juntamos a interface de rede com o firewall criado, ou melhor, security group
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
