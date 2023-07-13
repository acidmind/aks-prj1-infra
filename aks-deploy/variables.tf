variable "location" {
  description = "Location"
  type        = string
  default     = "centralindia"
}

variable "aks_rg_name" {
  description = "RG Name"
  type        = string
  default     = "aks-prj1-rg"
}

variable "prj1_rg_name" {
  description = "Location"
  type        = string
  default     = "prj1-rg"
}

variable "prj1_vnet_name" {
  description = "Location"
  type        = string
  default     = "prj1-vnet"
}

variable "prj1_address_space" {
  description = "Location"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_prefix" {
  description = "Location"
  type        = string
  default     = "10.0.1.0/24"
}


