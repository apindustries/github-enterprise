resource "github_repository" "module_template_repo" {
    for_each   = var.tf_module_template_repo
    name       = "tf-${replace(lower(each.key), " ", "")}"
    visibility = var.github_plan == "Enterprise" ? "internal" : "private"
    lifecycle {
        ignore_changes = [
        description
        ]
    }
}