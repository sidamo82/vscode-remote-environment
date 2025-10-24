terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable "socket" {
  type        = string
  description = <<-EOF
  The Unix socket that the Docker daemon listens on and how containers
  communicate with the Docker daemon.

  Either the Unix socket or the Docker host can be used.
  EOF
  default     = "/var/run/docker.sock"
}

variable "cpu_cores" {
  description = "Number of CPU cores for the workspace"
  type        = number
  default     = 2
  validation {
    condition     = var.cpu_cores >= 1 && var.cpu_cores <= 8
    error_message = "CPU cores must be between 1 and 8."
  }
}

variable "memory_gb" {
  description = "Amount of memory in GB for the workspace"
  type        = number
  default     = 4
  validation {
    condition     = var.memory_gb >= 2 && var.memory_gb <= 16
    error_message = "Memory must be between 2 and 16 GB."
  }
}

provider "docker" {
  host = "unix://${var.socket}"
}

provider "coder" {}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

# Coder agent for the main development container
resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    #!/bin/bash
    set -e
    
    # Wait for workspace to be ready
    while [ ! -f "/workspaces/startup.sh" ]; do
      echo "Waiting for workspace files..."
      sleep 5
    done
    
    # Make startup script executable and run it
    chmod +x /workspaces/startup.sh
    /workspaces/startup.sh
  EOT

  # Environment variables for git configuration
  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.coder_workspace_owner.me.email}"
  }

  # Metadata for workspace monitoring
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
  }
}

# VS Code Server application
resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:13337/?folder=/workspaces"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

# PHP Development Server Apps
resource "coder_app" "php73" {
  agent_id     = coder_agent.main.id
  slug         = "php73"
  display_name = "PHP 7.3 Server"
  url          = "http://localhost:8073"
  icon         = "/icon/php.svg"
  subdomain    = false
  share        = "owner"
}

resource "coder_app" "php74" {
  agent_id     = coder_agent.main.id
  slug         = "php74"
  display_name = "PHP 7.4 Server"
  url          = "http://localhost:8074"
  icon         = "/icon/php.svg"
  subdomain    = false
  share        = "owner"
}

resource "coder_app" "php80" {
  agent_id     = coder_agent.main.id
  slug         = "php80"
  display_name = "PHP 8.0 Server"
  url          = "http://localhost:8080"
  icon         = "/icon/php.svg"
  subdomain    = false
  share        = "owner"
}

resource "coder_app" "php82" {
  agent_id     = coder_agent.main.id
  slug         = "php82"
  display_name = "PHP 8.2 Server"
  url          = "http://localhost:8082"
  icon         = "/icon/php.svg"
  subdomain    = false
  share        = "owner"
}

resource "coder_app" "php84" {
  agent_id     = coder_agent.main.id
  slug         = "php84"
  display_name = "PHP 8.4 Server"
  url          = "http://localhost:8084"
  icon         = "/icon/php.svg"
  subdomain    = false
  share        = "owner"
}

# Docker resources
resource "docker_network" "main" {
  name = "coder-${data.coder_workspace.me.id}"
}

resource "docker_volume" "workspaces" {
  name = "coder-${data.coder_workspace.me.id}-workspaces"
}

resource "docker_volume" "mariadb_data" {
  name = "coder-${data.coder_workspace.me.id}-mariadb"
}

# Main development container using envbuilder
resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = "ghcr.io/coder/envbuilder:latest"
  name  = "coder-${data.coder_workspace_owner.me.name}-${data.coder_workspace.me.name}"

  hostname = data.coder_workspace.me.name

  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.1/", "host.docker.internal")]

  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "ENVBUILDER_GIT_URL=https://github.com/sidamo82/vscode-remote-environment.git",
    "ENVBUILDER_INIT_SCRIPT=/workspaces/startup.sh",
    "WORKSPACE_FOLDER=/workspaces",
    "ENVBUILDER_DEVCONTAINER_DIR=.devcontainer",
    "ENVBUILDER_DOCKER_CONFIG_BASE64=", # Allow docker-in-docker
  ]

  # Resource limits
  memory = var.memory_gb * 1024
  cpus   = var.cpu_cores

  # Privileged mode for docker-in-docker (required for devcontainer)
  privileged = true

  networks_advanced {
    name = docker_network.main.name
  }

  volumes {
    container_path = "/workspaces"
    volume_name    = docker_volume.workspaces.name
  }

  # Mount Docker socket for docker-in-docker
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  # Port mappings for PHP development servers
  ports {
    internal = 8073
    external = 8073
  }

  ports {
    internal = 8074
    external = 8074
  }

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 8082
    external = 8082
  }

  ports {
    internal = 8084
    external = 8084
  }

  ports {
    internal = 3306
    external = 3306
  }

  ports {
    internal = 9003
    external = 9003
  }

  ports {
    internal = 13337
    external = 13337
  }

  # Labels for Coder resource tracking
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }

  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }

  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }

  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}

data "coder_provisioner" "me" {}