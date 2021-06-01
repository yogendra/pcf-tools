

.PHONY: all
all: yogendra_ubuntu pcfjupbox kubeshell

ubuntu: yogendra_ubuntu_bionic yogendra_ubuntu_user yogendra_ubuntu_workspace 

yogendra_ubuntu_bionic: 
	@docker build -f yogendra_ubuntu_bionic.Dockerfile -t yogendra/ubuntu:latest -t yogendra/ubuntu:bionic  .
	@docker push yogendra/ubuntu:latest 
	@docker push yogendra/ubuntu:bionic 

yogendra_ubuntu_user: yogendra_ubuntu_bionic
	@docker build -f yogendra_ubuntu_user.Dockerfile -t yogendra/ubuntu:user .
	@docker push yogendra/ubuntu:user 

yogendra_ubuntu_workspace: yogendra_ubuntu_bionic
	@docker build -f yogendra_ubuntu_workspace.Dockerfile -t yogendra/ubuntu:workspace -t yogendra/workspace:latest .
	@docker push yogendra/ubuntu:workspace
	@docker push yogendra/workspace:latest


pcfjumpbox2:	
	@DOCKER_BUILDKIT=1  docker build  --secret id=jumbox-secrets,src=${PWD}/script/secrets.sh -f yogendra_pcf-jumpbox2.Dockerfile -t yogendra/pcf-jumpbox2:latest .

pcfjumpbox: 
	- docker stop secrets 
	- docker network rm  buildnet
	@docker network create buildnet
	@docker run --name secrets --rm --volume $PWD:/usr/share/nginx/html:ro --network buildnet -d nginx
	@docker run --name secrets-consumer --rm --network buildnet -t busybox wget -qO- http://secrets/config/secrets.sh | wc -c
	@docker build -f yogendra_pcf-jumpbox.Dockerfile -t yogendra/pcf-jumpbox:latest .
	- docker stop secrets 
	- docker network rm  buildnet

kubeshell: yogendra_ubuntu_user
	@docker build -t yogendra/kubeshell -f yogendra_kubeshell.Dockerfile .
	- docker push yogendra/kubeshell 
