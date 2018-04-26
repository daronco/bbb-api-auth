SHELL=/bin/bash

image-dev:
	docker build -t bigbluebutton/bbb-api-auth:dev .

run-dev:
	docker run --rm -ti -e APP_HOST=localhost -p 80:80 -p 443:443 bigbluebutton/bbb-api-auth:dev
