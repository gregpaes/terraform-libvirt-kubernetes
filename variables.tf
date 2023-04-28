# variables that can be overriden
variable "hostname" {
  type = list(string)
  default = ["master", "worker01", "worker02"]
}

variable "domain" { 
  default = "cluster01" 
}

variable "memoryMB" { 
  default = 2048
}

variable "cpu" { 
  default = 2
}

variable "sizeBytes" { 
  default = 1073741824*5
}
