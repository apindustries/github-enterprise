variable "admins" {
  type = set(string)
}

variable "members" {
  type = set(string)
}

variable "teams" {
  type = list(object({
    name    = string
    members = optional(set(string))
    repos   = optional(set(string))
  }))
}

variable "tf_module_repos" {
  type = set(string)
}