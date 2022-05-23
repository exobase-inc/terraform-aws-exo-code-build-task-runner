
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

variable "use_bridge" {
  type = bool
  default = false
  description = "Should a standard bridge API be deployed? You'll be able to make the same API call to the bridge between different packs that produce a task runner in other cloud providers or using other cloud services."
}


//
//  Exobase Provided
//

variable "exo_context" {
  type = string // json:DeploymentContext
}

variable "exo_source" {
  type = string // path to source
}