SHELL=/bin/bash

.PHONY: all image

all: image

# Build a docker image using the configurations from the environment variables
image:
	docker build -t bigbluebutton/bbb-api-auth .
