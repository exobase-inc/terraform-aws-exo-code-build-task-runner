
//
//  User Input
//

variable "timeout" {
  type = number
  default = 5
  description = "Maximum time (in minutes) the build is allowed to run before AWS will kill it. Valid values between 5-480."
}

variable "command" {
  type = string
  description = "The command to execute the build. Runs from the root directory of your source."
}

variable "image" {
  type = string
  default = "node:16"
  description = "The docker image to execute the build in."
}

variable "envvars" {
  type = string
  default = "[]"
  description = "Environment variables available to your build"
}


//
//  Exobase Provided
//

variable "exo_context" {
  type = string // json:DeploymentContext
}
