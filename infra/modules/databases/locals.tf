locals {
  source_path      = abspath("${path.module}/../../src")
  docker_file_path = "functions/datasets_objects_maker/Dockerfile"
  path_include     = ["functions/datasets_objects_maker/requirements.txt", "functions/datasets_objects_maker/src/**"]
  files_include    = sort(setunion([for f in local.path_include : fileset(local.source_path, f)]...))
  dir_sha          = sha1(join("", [for f in local.files_include : filesha1("${local.source_path}/${f}")]))
}
