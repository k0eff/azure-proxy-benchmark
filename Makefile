include ./.env
export

init:
	terraform init

apply:
	terraform apply -parallelism=30 plan.out 

plan:
	rm -f plan.out
	terraform plan -parallelism=30 -out plan.out

destroy:
	terraform destroy -parallelism=30

taint:
	terraform taint $(t)

untaint:
	terraform untaint $(t)

refresh:
	terraform refresh

import:
	terraform import $(r) $(u)
	