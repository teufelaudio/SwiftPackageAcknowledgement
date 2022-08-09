prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib

build:
	swift build -c release --disable-sandbox --arch arm64 --arch x86_64

install: build
	install ".build/apple/Products/Release/spm-ack" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/spm-ack"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
