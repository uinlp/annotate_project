locals {
  package_name     = "backend"
  source_path      = abspath("${path.module}/../../../packages")
  docker_file_path = "${local.source_path}/${local.package_name}/Dockerfile"

  # 1. Read the .ignore file
  ignore_path    = "${local.source_path}/${local.package_name}/.gitignore"
  ignore_content = fileexists(local.ignore_path) ? file(local.ignore_path) : ""

  # 2. Parse the lines (remove comments, empty lines, and handle Windows/Unix line endings)
  ignore_lines = [
    for line in split("\n", replace(local.ignore_content, "\r\n", "\n")) :
    trimspace(line)
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
  ]

  # 3. Merge your explicit excludes with the .ignore lines
  path_exclude  = local.ignore_lines
  path_include  = ["internal", local.package_name]
  files_include = setunion([for f in local.path_include : fileset(local.source_path, f)]...)
  files_exclude = setunion([for f in local.path_exclude : fileset(local.source_path, f)]...)
  files         = sort(setsubtract(local.files_include, local.files_exclude))
  dir_sha       = sha1(join("", [for f in local.files : filesha1("${local.source_path}/${f}")]))
}
