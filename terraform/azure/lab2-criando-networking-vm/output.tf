output "vm_name" {
  description = "Nome da máquina virtual"
  value       = azurerm_linux_virtual_machine.this.name
}

output "public_ip_address" {
  description = "Ip publico da máquina virtual"
  value       = azurerm_public_ip.this.ip_address
}