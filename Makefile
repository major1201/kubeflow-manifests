KFCTL_YAML=kubeflow/kfctl_k8s_istio.v1.0.2.yaml
# KFCTL_YAML=kubeflow/kfctl_istio_dex.v1.0.2.yaml

.PHONY: help
all: help
## help: List all supported make commands.
help: Makefile
	@echo
	@echo "Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo


## clean: delete caches
clean:
	rm -f release/*
	rm -rf kubeflow/.cache
	rm -rf kubeflow/kustomize


## fileserver: start a fileserver
fileserver:
	@docker run -d --name kubeflow-fileserver -v $$(pwd):/var/www/html -p 127.0.0.1:8089:80 major1201/fileserver


## release: release a version
release: clean
	@mkdir -p release
	@gtar czf release/manifests-1.0.2.tar.gz --exclude .git --exclude release --exclude kubeflow --transform 's,^,manifests-1.0.2/,' .
	@kfctl build -V -f $(KFCTL_YAML)
	@rm -f release/manifests-1.0.2.tar.gz
	@echo "info: Please use kustomize v3.2.3"
	@grep "^    name: " $(KFCTL_YAML) | awk '{print $$2}' | while read line; do echo $$line; kustomize build kubeflow/kustomize/$$line > release/$$line.yaml; done


## install: install the released version
install:
	@kubectl create ns kubeflow || echo "ns kubeflow already installed."
	@grep "^    name: " $(KFCTL_YAML) | awk '{print $$2}' | while read line; do echo ""; echo Installing $$line ...; kubectl apply -f release/$$line.yaml && sleep 10; done


## uninstall: uninstall the released version
uninstall:
	@grep "^    name: " $(KFCTL_YAML) | awk '{print $$2}' | tail -r | while read line; do echo ""; echo Uninstalling $$line ...; kubectl delete -f release/$$line.yaml; done
	@kubectl delete ns kubeflow
