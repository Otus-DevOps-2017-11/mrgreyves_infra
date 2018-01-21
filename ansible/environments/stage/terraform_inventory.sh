#!/usr/bin/env bash
env="stage"
TF_STATE=../terraform/${env}/terraform.tfstate terraform-inventory $1