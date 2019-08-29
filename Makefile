VERSION := $(shell cat ./VERSION).
LDFLAGS += -X "main.BuildTimestamp=$(shell date -u "+%Y-%m-%d %H:%M:%S")"
LDFLAGS += -X "main.Version=$(VERSION)$(shell git rev-parse --short HEAD)"

GO := GO111MODULE=on go

.PHONY: init
init:
	go get -u golang.org/x/lint/golint
	go get -u golang.org/x/lint/golint
	go get -u golang.org/x/tools/cmd/goimports
	@echo "Install pre-commit hook"
	@chmod +x ./hack/check.sh
	@chmod +x $(shell pwd)/hooks/pre-commit
	@ln -sf $(shell pwd)/hooks/pre-commit $(shell pwd)/.git/hooks/pre-commit || true

.PHONY: setup
setup: init
	git init

.PHONY: check
check:
	@./hack/check.sh ${scope}

.PHONY: ci
ci: init
	@$(GO) mod tidy && $(GO) mod vendor

.PHONY: clean
clean:
	@$(GO) clean ./server/go-template

.PHONY: build
build: check
	$(GO) build -o ./tmp/go-template -ldflags '$(LDFLAGS)' ./server/go-template

.PHONY: install
install: check
	@echo "Installing..."
	$(GO) install -ldflags '$(LDFLAGS)' ./server/go-template

.PHONY: release
release: check
	GOOS=darwin GOARCH=amd64 $(GO) build -ldflags '$(LDFLAGS)' -o bin/macos/go-template ./server/go-template
	GOOS=linux GOARCH=amd64 $(GO) build -ldflags '$(LDFLAGS)' -o bin/linux/go-template ./server/go-template
	GOOS=windows GOARCH=amd64 $(GO) build -ldflags '$(LDFLAGS)' -o bin/windows/go-template.exe ./server/go-template

.PHONY: docker-image
docker-image:
	docker build -t andodevel/go-template:v1.10 -f ./Dockerfile .
