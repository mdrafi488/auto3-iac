variable "public_cidr" {
  type    = list(any)
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  #description = "description"
}
variable "pvt_cidr" {
  type    = list(any)
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  #description = "description"
}
variable "data_cidr" {
  type    = list(any)
  default = ["10.1.7.0/24", "10.1.8.0/24", "10.1.9.0/24"]
  #description = "description"
}
