K=kubectl

.PHONY: help clean update build build-dev docker-build docker-run start-proxies stop-proxies

help:	# The following lines will print the available commands when entering just 'make'
ifeq ($(UNAME), Linux)
	@grep -P '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
else
	@awk -F ':.*###' '$$0 ~ FS {printf "%15s%s\n", $$1 ":", $$2}' \
		$(MAKEFILE_LIST) | grep -v '@awk' | sort
endif

clean: ### Removes the tracking of using packages
	rm -rf .build
	rm -rf Package.resolved

resolve: ### Fetch packages
	swift package resolve

update: ### Updates the project dependencies
	swift package update

build: resolve ### Compiles the code in debug mode
	swift build

test: resolve
	swift test
