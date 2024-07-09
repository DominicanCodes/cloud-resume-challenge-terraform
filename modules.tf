# set source for website files
module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/website"
}
