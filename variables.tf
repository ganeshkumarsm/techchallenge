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
