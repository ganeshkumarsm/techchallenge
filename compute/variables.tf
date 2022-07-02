# --- compute/variables.tf ---

variable "instance_count" {}
variable "instance_type" {}
variable "public_sg" {}
variable "public_subnets" {}
variable "vol_size" {}
variable "key_name" {}
variable "dbuser" {
    type = string
    sensitive = true
}
variable "dbname" {}
variable "dbpassword" {
    type = string
    sensitive = true
}
variable "db_endpoint" {}
variable "user_data_path" {}
variable "lb_target_group_arn" {}