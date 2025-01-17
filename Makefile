BASE_DIR=$(shell echo $$GOPATH)/src/github.com/errata-ai/vale
BUILD_DIR=./builds

LAST_TAG=$(shell git describe --abbrev=0 --tags)
CURR_SHA=$(shell git rev-parse --verify HEAD)

LDFLAGS=-ldflags "-s -w -X main.version=$(LAST_TAG)"

.PHONY: data test lint cross install bump rules setup bench compare release

all: build

# make release tag=v0.4.3
release:
	git tag $(tag)
	git push origin $(tag)

build:
	go build ${LDFLAGS} -o bin/vale

build-win:
	go build ${LDFLAGS} -o vale.exe
	go-msi make --msi vale.msi --version $(LAST_TAG)

install:
	go install ${LDFLAGS}

spell:
	./bin/vale --glob='!*{Needless,Diacritical,DenizenLabels,AnimalLabels}.yml' rule styles

bench:
	go test -bench=. -benchmem ./core ./lint ./check

compare:
	cd lint && \
	benchmany -n 5 -o new.txt ${CURR_SHA} && \
	benchmany -n 5 -o old.txt ${LAST_TAG} && \
	benchcmp old.txt new.txt && \
	benchstat old.txt new.txt

lint:
	gometalinter --vendor --disable-all \
		--enable=deadcode \
		--enable=ineffassign \
		--enable=gosimple \
		--enable=staticcheck \
		--enable=goimports \
		--enable=dupl \
		--enable=misspell \
		--enable=errcheck \
		--enable=vet \
		--enable=vetshadow \
		--deadline=1m \
		./core ./lint ./ui ./check

setup:
	go get golang.org/x/perf/cmd/benchstat
	go get golang.org/x/tools/cmd/benchcmp
	go get github.com/aclements/go-misc/benchmany
	go get -u github.com/alecthomas/gometalinter
	go get -u github.com/jteeuwen/go-bindata/...
	bundle install
	gem specific_install -l https://github.com/jdkato/aruba.git -b d-win-fix

rules:
	go-bindata -ignore=\\.DS_Store -pkg="rule" -o rule/rule.go rule/**/*.yml

data:
	go-bindata -ignore=\\.DS_Store -pkg="data" -o data/data.go data/*.{dic,aff}

plugins:
	cd styles/plugins/ && \
	go build -buildmode=plugin Example.go && \
	go build -buildmode=plugin Sequence.go

test:
	go test -race ./core ./lint ./check
	cucumber
