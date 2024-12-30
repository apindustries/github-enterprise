output "github_repository_names" {
  value = {
    for repo in github_repository.module_template_repo : repo.name => repo
  }

}