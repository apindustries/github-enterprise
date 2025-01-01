locals {
  team_names = toset([for team in var.teams : team.name])
  team_slugs = [for team in var.teams : replace(lower(team.name), " ", "")]
  team_repos = toset(flatten([
    for team in var.teams : [
      for repo in team.repos != null ? team.repos : [] : replace(lower("${team.name}-${repo}"), " ", "")
    ]
  ]))
  team_members = {
    for kvp in flatten([
      for team in var.teams : [
        for idx, member in team.members != null ? team.members : [] :
        {
          team_name   = team.name
          member_name = member
        }
      ]
      ]) : "${kvp.team_name}-${kvp.member_name}" => {
      team_name   = kvp.team_name
      member_name = kvp.member_name
    }
  }
  repo_teams = {
    for kvp in flatten([
      for team in var.teams : [
        for repo in team.repos != null ? team.repos : [] : {
          team_name = team.name
          repo_name = replace(lower("${team.name}-${repo}"), " ", "")
        }
      ]
      ]) : "${kvp.team_name}-${kvp.repo_name}" => {
      team_name = kvp.team_name
      repo_name = kvp.repo_name
    }
  }
}

resource "github_organization_settings" "org" {
  name                                    = "apindustries"
  billing_email                           = "armando_pitotti@epam.com"
  blog                                    = ""
  default_repository_permission           = "none"
  has_organization_projects               = false
  has_repository_projects                 = false
  members_can_create_private_repositories = false
  members_can_create_public_repositories  = false
  members_can_create_repositories         = false
}

# 403 Upgrade to GitHub Enterprise to enable this feature.
# resource "github_organization_ruleset" "master-branch-protection" {
#   name        = "Master Branch Protection"
#   target      = "branch"
#   enforcement = "active"

#   bypass_actors {
#     actor_id    = 1
#     actor_type  = "OrganizationAdmin"
#     bypass_mode = "always"
#   }

#   conditions {
#     ref_name {
#       exclude = []
#       include = [
#         "~DEFAULT_BRANCH",
#       ]
#     }

#     repository_name {
#       exclude = []
#       include = [
#         "~ALL",
#       ]
#       protected = false
#     }
#   }

#   rules {
#     deletion         = true
#     non_fast_forward = true
#     pull_request {
#       dismiss_stale_reviews_on_push     = true
#       require_code_owner_review         = false
#       require_last_push_approval        = false
#       required_approving_review_count   = 1
#       required_review_thread_resolution = false
#     }
#   }
# }

data "github_user" "admin-user" {
  for_each = var.admins
  username = each.value
}

data "github_user" "member-user" {
  for_each = var.members
  username = each.value
}
# resource "github_repository_collaborator" "ghe-access" {
#   for_each   = var.members
#   repository = github_repository.github-enterprise.name
#   username   = each.value
#   permission = "push"
# }
# 422 Repository creation failed. [{Resource:Repository Field:name Code:custom Message:name already exists on this account}]
# resource "github_repository" "github-enterprise" {
#   name       = "github-enterprise"
#   visibility = var.github_plan == "Enterprise" ? "internal" : "public"
# }
resource "github_repository" "discussions" {
  name            = "discussions"
  visibility      = var.github_plan == "Enterprise" ? "internal" : "public"
  has_discussions = true
}
resource "github_repository" "github-templates" {
  name                 = ".github"
  visibility           = "public"
  vulnerability_alerts = true
}
resource "github_repository" "tfmod_repo" {
  for_each   = var.tf_module_repos
  name       = "tf-${replace(lower(each.key), " ", "")}"
  visibility = var.github_plan == "Enterprise" ? "internal" : "private"
  lifecycle {
    ignore_changes = [
      description
    ]
  }
}
# Create a README.md file in the root directory of the repository.
resource "github_repository_file" "tfmod_readme" {
  for_each   = var.tf_module_repos
  repository = "tf-${replace(lower(each.key), " ", "")}"
  branch     = "main"
  file       = "README.md"
  content    = "# This repository contains Terraform scripts."
  depends_on = [github_repository.tfmod_repo]
}
resource "github_repository" "team_repo" {
  for_each   = local.team_repos
  name       = each.key
  visibility = "private"
}
resource "github_team_repository" "tfmod_team_repo" {
  for_each   = var.tf_module_repos
  team_id    = github_team.team["Cloud Ops"].id
  repository = github_repository.tfmod_repo[each.value].name
  permission = "push"
}

resource "github_membership" "admin" {
  for_each = var.admins
  username = each.value
  role     = "admin"
}

resource "github_membership" "member" {
  for_each = var.members
  username = each.value
  role     = "member"
}

resource "github_team" "team" {
  for_each = local.team_names
  name     = each.key
  privacy  = "closed"
}

resource "github_team_membership" "team_member" {
  for_each = local.team_members
  team_id  = github_team.team[each.value.team_name].id
  username = each.value.member_name
}

resource "github_team_repository" "team_repo" {
  for_each   = local.repo_teams
  team_id    = github_team.team[each.value.team_name].id
  repository = github_repository.team_repo[each.value.repo_name].name
  permission = "push"
}
