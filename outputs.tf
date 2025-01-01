output "github_repository_modules_name" {
  value = {
    for repo in github_repository.tfmod_repo : repo.name => repo.name
  }

}