terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "000000-000000-000000-0000000-00000"
  client_id       = "000000-000000-000000-0000000-00000"
  client_secret   = "hBw8Q~EMmeX6H~FzfJHR0jhsdvfksujbkrgufj"
  tenant_id       = "000000-000000-000000-0000000-00000"
  features {}
}

locals {
  resource_group = "test-tfrg"
  location       = "East US"
}


resource "azurerm_resource_group" "test-rg" {
  name     = local.resource_group
  location = local.location
}

variable "vitual_network_name" {
  type    = string
  default = "tf-vnet"
}



resource "azurerm_virtual_network" "tf-vnet" {
  name                = var.vitual_network_name
  location            = local.location
  resource_group_name = azurerm_resource_group.test-rg.name
  address_space       = ["10.0.0.0/16"]

  depends_on = [azurerm_resource_group.test-rg]
}

// adding subnet 8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

resource "azurerm_subnet" "tf-subnet" {
  name                 = "my-tf-subnet"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.tf-vnet]
}

//network interface for vm1 99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999

resource "azurerm_network_interface" "tf-nic1" {
  name                = "tf-nic1"
    location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_virtual_network.tf-vnet,
    azurerm_subnet.tf-subnet
  ]
}

//network interface for vm2 99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999

resource "azurerm_network_interface" "tf-nic2" {
  name                = "tf-nic2"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_virtual_network.tf-vnet,
   azurerm_subnet.tf-subnet
  ]
}

//windows virtual machine 1 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

resource "azurerm_windows_virtual_machine" "tf-vm1" {
  name                = "tf-vm1"
    location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  admin_password = "Admin@123456789"
  availability_set_id = azurerm_availability_set.tf-set.id
  network_interface_ids = [
    azurerm_network_interface.tf-nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.tf-nic1,
    azurerm_availability_set.tf-set
  ]
}

//windows virtual machine 1 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

resource "azurerm_windows_virtual_machine" "tf-vm2" {
  name                = "tf-vm2"
    location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  admin_password = "Admin@123456789"
  availability_set_id = azurerm_availability_set.tf-set.id
  network_interface_ids = [
    azurerm_network_interface.tf-nic2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.tf-nic2,
    azurerm_availability_set.tf-set
  ]
}

// avilability set 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
resource "azurerm_availability_set" "tf-set" {
  name                         = "tf-set"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3

  depends_on = [
    azurerm_resource_group.test-rg
  ]
}

// storage account 88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888


resource "azurerm_storage_account" "tf-store" {
  name                          = "appstore76543456"
    location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true

  depends_on = [azurerm_resource_group.test-rg]
}

resource "azurerm_storage_container" "tf-contain" {
  name                  = "tf-contain"
  storage_account_id    = azurerm_storage_account.tf-store.id
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.tf-store
  ]
}

//virtual machine iis server install 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 

resource "azurerm_storage_blob" "IIS_config" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = azurerm_storage_account.tf-store.name
  storage_container_name = "tf-contain"
  type                   = "Block"
  source                 = "IIS_Config.ps1"
  depends_on             = [azurerm_storage_container.tf-contain]
}

// this is extention for vm 1

resource "azurerm_virtual_machine_extension" "vm_extension1" {
  name                       = "appvm-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.tf-vm1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_storage_blob.IIS_config,
    azurerm_resource_group.test-rg
  ]
  settings = <<SETTINGS
    {
      "fileUris": ["https://${azurerm_storage_account.tf-store.name}.blob.core.windows.net/${azurerm_storage_container.tf-contain.name}/IIS_Config.ps1"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1" 
    }
SETTINGS

}

// this is extention for vm 2

resource "azurerm_virtual_machine_extension" "vm_extension2" {
  name                       = "appvm-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.tf-vm2.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_storage_blob.IIS_config,
    azurerm_resource_group.test-rg
  ]
  settings = <<SETTINGS
    {
      "fileUris": ["https://${azurerm_storage_account.tf-store.name}.blob.core.windows.net/${azurerm_storage_container.tf-contain.name}/IIS_Config.ps1"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1" 
    }
SETTINGS

}

# //nsg rules create 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
   location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  # We are creating a rule to allow traffic on port 80
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.test-rg]
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.tf-subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg,
    azurerm_resource_group.test-rg
  ]
}



// Lets create the Load balancer

resource "azurerm_public_ip" "load_ip" {
  name                = "load-ip"
location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  allocation_method   = "Static"
  sku="Standard"
}

resource "azurerm_lb" "app_balancer" {
  name                = "app-balancer"
location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  sku="Standard"
  sku_tier = "Regional"
  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.load_ip.id
  }

  depends_on=[
    azurerm_public_ip.load_ip
  ]
}

// Here we are defining the backend pool
resource "azurerm_lb_backend_address_pool" "PoolA" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "PoolA"
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm1_address" {
  name                    = "appvm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id      = azurerm_virtual_network.tf-vnet.id
  ip_address              = azurerm_network_interface.tf-nic1.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.PoolA
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm2_address" {
  name                    = "appvm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id      = azurerm_virtual_network.tf-vnet.id
  ip_address              = azurerm_network_interface.tf-nic2.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.PoolA
  ]
}


// Here we are defining the Health Probe
resource "azurerm_lb_probe" "ProbeA" {
  loadbalancer_id     = azurerm_lb.app_balancer.id
  name                = "probeA"
  port                = 80
  protocol            =  "Tcp"
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

// Here we are defining the Load Balancing Rule
resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.PoolA.id ]
  depends_on=[
    azurerm_lb.app_balancer
  ]
}



