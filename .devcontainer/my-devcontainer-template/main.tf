terraform {
  required_providers {
    coder = {
      source = "coder/coder"
      version = ">= 0.0.3"
    }
  }
}

provider "coder" {}

data "coder_parameter" "git_repo" {
  name         = "git_repo"
  display_name = "Git repository"
  default      = "https://x-token-auth:${var.bitbucket_access_token}@bitbucket.org/novigo-consulting/vscode-remote-environment.git"
}

resource "coder_agent" "dev" {
  name           = "dev-container"
  image          = "coder/code-server:latest"
  agent_id       = "dev-agent"
  workspace      = true
  dir            = "~/workspace"
  startup_script = <<-EOT
    if [ ! -d "~/workspace" ]; then
      git clone ${data.coder_parameter.git_repo.value} ~/workspace
    fi
  EOT
}
