resource "azurerm_resource_group" "prrg" {
  name     = "pr-rg2"
  location = "East US"
}
# Create virtual network
resource "azurerm_virtual_network" "prvnet" {
  name                = "pr-tf-vm"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.prrg.name
}
# Create subnet
resource "azurerm_subnet" "prsubnet" {
  name                 = "pr-tf-subnet"
  resource_group_name  = azurerm_resource_group.prrg.name
  virtual_network_name = azurerm_virtual_network.prvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create public IPs
resource "azurerm_public_ip" "prpublicip" {
  name                = "pr-tf-public-ip"
  location            = "East US"
  resource_group_name = azurerm_resource_group.prrg.name
  allocation_method   = "Static"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "prnsg" {
  name                = "pr-tf-nsg"
  location            = "East US"
  resource_group_name = azurerm_resource_group.prrg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443", "32323"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
# Create network interface
resource "azurerm_network_interface" "prnic" {
  name                = "pr-tf-nic"
  location            = "East US"
  resource_group_name = azurerm_resource_group.prrg.name

  ip_configuration {
    name                          = "pr-tf-nic-configuration"
    subnet_id                     = azurerm_subnet.prsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prpublicip.id
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "prnicass" {
  network_interface_id      = azurerm_network_interface.prnic.id
  network_security_group_id = azurerm_network_security_group.prnsg.id
}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "prvm" {
  name                  = "pr-tf-vm"
  location              = "East US"
  resource_group_name   = azurerm_resource_group.prrg.name
  network_interface_ids = [azurerm_network_interface.prnic.id]
  size                  = "Standard_A2_v2"

  os_disk {
    name                 = "pr-osDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "pr-tf-vm"
  admin_username                  = "aminabhi"
  admin_password                  = "prtfvm@235"
  disable_password_authentication = false
}