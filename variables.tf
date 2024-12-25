variable "github_plan" {
  type    = string
  default = "Team"
  validation {
    condition     = contains(["Free", "Team", "Enterprise"], var.github_plan)
    error_message = "Invalid GitHub plan. Must be one of: Free, Team, Enterprise"
  }

}
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