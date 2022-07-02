variable "region" {
  default = "ap-south-1"
}

variable "access_ip" {

}

variable "dbname" {
  type      = string
  sensitive = true
}
variable "dbuser" {
  type      = string
  sensitive = true
}
variable "dbpassword" {
  type      = string
  sensitive = true
}

# variable "access_key" {
#   default = "AKIAR7D3XETV6PP7WGOK"
# }

# variable "secret_key" {
#   default = "c0QyxmPfG4I0JVkdLBRw0nQKnqgSliXFztVBnlAb"
# }

