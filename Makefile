IMAGE := jetstackexperimental/squid
IMAGE_TAG := canary

image:
	docker build -t $(IMAGE):$(IMAGE_TAG) .

push: image
	docker push $(IMAGE):$(IMAGE_TAG)
