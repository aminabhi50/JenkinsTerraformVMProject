output "vm_public_ip" {
  description = "Public IP of virtual machine"
  value       = azurerm_linux_virtual_machine.prvm.public_ip_address
}
