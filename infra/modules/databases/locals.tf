locals {
  package_name     = "datasets-objects-maker"
  source_path      = abspath("${path.module}/../../../packages")
  docker_file_path = "${local.source_path}/${local.package_name}/Dockerfile"

  # 1. Read the .dockerignore file
  dockerignore_path    = "${local.source_path}/${local.package_name}/.dockerignore"
  dockerignore_content = fileexists(local.dockerignore_path) ? file(local.dockerignore_path) : ""

  # 2. Parse the lines (remove comments, empty lines, and handle Windows/Unix line endings)
  dockerignore_lines = [
    for line in split("\n", replace(local.dockerignore_content, "\r\n", "\n")) :
    trimspace(line)
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
  ]

  # 3. Merge your explicit excludes with the .dockerignore lines
  path_exclude  = distinct(concat(["**/__pycache__", "**/.aws-sam"], local.dockerignore_lines))
  path_include  = ["internal", local.package_name]
  files_include = setunion([for f in local.path_include : fileset(local.source_path, f)]...)
  files_exclude = setunion([for f in local.path_exclude : fileset(local.source_path, f)]...)
  files         = sort(setsubtract(local.files_include, local.files_exclude))
  dir_sha       = sha1(join("", [for f in local.files : filesha1("${local.source_path}/${f}")]))
}
