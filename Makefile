CRYSTAL_BIN ?= crystal
SHARDS_BIN ?= shards
PREFIX ?= /usr/local
SHARD_BIN ?= ../../bin

build: bin/crkcov
bin/crkcov:
	$(SHARDS_BIN) build --without-development $(CRFLAGS)
clean:
	rm -f ./bin/crkcov ./bin/crkcov.dwarf
bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/crkcov $(SHARD_BIN)
