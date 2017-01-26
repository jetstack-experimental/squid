IMAGE := jetstackexperimental/squid
IMAGE_TAGS := canary

image:
	docker build -t $(IMAGE):$(IMAGE_TAG) .

push: image
	set -e; \
	for tag in $(IMAGE_TAGS); do \
		docker tag $(REGISTRY)/$(IMAGE_NAME):$(BUILD_TAG) $(REGISTRY)/$(IMAGE_NAME):$${tag} ; \
		docker push $(REGISTRY)/$(IMAGE_NAME):$${tag}; \
	done
