terraform {
  required_version = "~> 0.13.0"
  required_providers {
    github = {
      source  = "hashicorp/github"
      version = "~> 2.4"
    }
  }
}

provider "github" {
  token        = var.github_token
  organization = "18f"
}

locals {
  repos = {
    "aws-admin" : {},
    "before-you-ship" : {},
    "billing-tools" : { archived = true },
    "bug-bounty" : {},
    "certificate-service" : { archived = true },
    "chandika" : { archived = true },
    "chat" : {},
    "deploy-ttslicenses" : { archived = true },
    "dns" : { skip_issue_templates = true },
    "ghad" : {},
    "handbook" : { skip_issue_templates = true },
    "laptop" : { skip_issue_templates = true },
    "raktabija" : { archived = true },
    "slack-export-handling" : { archived = true },
    "tts-tech-portfolio-private" : {},
    "tts-tech-portfolio" : {},
    "vulnerability-disclosure-policy" : {},
  }
}

module "repo" {
  source = "./repo"

  # skip archived repositories
  for_each        = { for repo, config in local.repos : repo => config if ! lookup(config, "archived", false) }
  repo            = each.key
  issue_templates = lookup(each.value, "skip_issue_templates", false) ? [] : ["general.md"]
}

resource "local_file" "github_repos" {
  content              = templatefile("${path.module}/github.md.tmpl", { repos = local.repos })
  filename             = "${path.module}/../how_we_work/github.md"
  file_permission      = "0644"
  directory_permission = "0755"
}
