variable "region" {
    type = string
    default = "ap-southeast-2"
}

variable "cat_feeder_thing_lambda_name" {
    type = string
    default = "CatFeederThingLambda"
}

variable "cat_feeder_thing_lambda_action_topic_name" {
    type = string
    default = "cat-feeder/action"
}

variable "cat_feeder_thing_controller_name" {
    type = string
    default = "CatFeederThingESP32"
}

variable "cat_feeder_thing_controller_states_topic_name" {
    type = string
    default = "cat-feeder/states"
}