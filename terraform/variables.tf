variable "project" {
  description = "GCP Project ID"
}
variable "region" {
  description = "GCP Deployment region"
}
variable "name" {
  description = "Name to use for GCP resources related created by this terraform"
  default = "newsaas"
}
variable "image" {
  description = "URL to container image with Calibre and REST API"
  default = "ghcr.io/pmalkiewicz/newsaas:main"
}
variable "smtp_username" {
  description = "Username of your email account that will be used to send emails with ebooks, for example user@example.com"
}
variable "smtp_password" {
  description = "Password of your email account that will be used to send emails with ebooks"
}
variable "smtp_server" {
  description = "Hostname of your email provider SMTP server, for example smtp.example.com"
}
variable "smtp_port" {
  description = "Port of your email provider SMTP server"
  default = "587"
}
variable "timeout" {
  description = "Calibre ebook conversion and email send execution timeout in seconds"
  default = "600"
}
variable "schedule" {
  description = "Cron-like syntax execution schedule, for example '0 7 * * 6' to execute the job every friday at 7am"
}
variable "recipe" {
  description = "Name of the built-in Calibre recipe, for example 'BBC News'"
}
variable "emails" {
  description = "List of emails to send ebook to, for example [\"email1@example.com\", \"email2@example.com\"]"
  type = list(string)
}
