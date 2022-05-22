
#
# For testing.
#

.PHONY: init
init:
	terraform init

.PHONY: plan
plan:
	terraform plan -var="exo_context={\"service\":{\"name\":\"Demo 2\",\"id\":\"exo.service.3jdfj9ijfwij02\"}}"

.PHONY: apply
apply:
	terraform apply -var="exo_context={\"service\":{\"name\":\"Demo 2\",\"id\":\"exo.service.3jdfj9ijfwij02\"}}"

#
# Publishing
#

.PHONY: login
login:
	exobase login

.PHONY: publish
publish:
	exobase publish