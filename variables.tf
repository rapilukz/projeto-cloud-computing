variable "location" {
    type      = string
    default   = "South Africa North"
    description = "The Azure region where resources will be created."
}

variable "prefix" {
    type        = string
    default     = "projeto-cf"
    description = "A prefix for resource names to ensure uniqueness."
}

variable db_admin_username {
    type        = string
    default     = "dbadmin"
    description = "The username for the database administrator."
}

variable db_admin_password {
    type        = string
    default     = "P@ssw0rd1234!"
    description = "The password for the database administrator."
}

variable "db_name" {
    type        = string
    default     = "carsdb"
    description = "The name of the database to be created."
}