locals {
  source_path      = abspath("${path.module}/../../src")
  docker_file_path = "functions/backend/Dockerfile"
  path_include = [
    "functions/backend/requirements.txt",
    "functions/backend/src/**",
    "scripts/internal/src/**",
    "scripts/internal/pyproject.toml",
  ]
  files_include = sort(setunion([for f in local.path_include : fileset(local.source_path, f)]...))
  dir_sha       = sha1(join("", [for f in local.files_include : filesha1("${local.source_path}/${f}")]))
}
