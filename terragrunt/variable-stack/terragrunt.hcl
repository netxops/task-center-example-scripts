terraform {
  source = "./module"
}

inputs = {
  environment  = "dev"
  service_name = "task-center"
  operator     = "oneops"
}
