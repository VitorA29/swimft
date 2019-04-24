SRC_FROM_BIN = ../../../../src
OUTPUT_FOLDER = ./output
OUT_FROM_BIN = ../../../../output
ENV = ./enviroment
EXAMPLES = ./examples
SWIFT_RELEASE = swift-5.0-RELEASE-ubuntu18.04
SWIFT_BIN = $(ENV)/$(SWIFT_RELEASE)/usr/bin

.SILENT: install_swift download_swift prepare_output compile_src clean_output execute_output clean_enviroment

all: download_swift compile_src execute_output

execute_output: compile_src
	./$(OUTPUT_FOLDER)/main $(EXAMPLES)/no_loop.imp;

compile_src: prepare_output
	cd $(SWIFT_BIN) && \
	./swiftc -o $(OUT_FROM_BIN)/main $(SRC_FROM_BIN)/main.swift $(SRC_FROM_BIN)/lib/*/*.swift;

prepare_output:
	if [ ! -d $(OUTPUT_FOLDER) ]; \
	then mkdir $(OUTPUT_FOLDER); fi

install_swift:
	if [ ! -d $(ENV) ]; \
	then \
		sudo apt-get install clang libicu-dev libcurl libcurl4-openssl-dev; fi

download_swift: install_swift
	if [ ! -d $(ENV) ]; \
	then \
		mkdir $(ENV); \
		cd $(ENV) && \
		wget https://swift.org/builds/swift-5.0-release/ubuntu1804/swift-5.0-RELEASE/$(SWIFT_RELEASE).tar.gz && \
		tar -xvzf $(SWIFT_RELEASE).tar.gz && \
		rm $(SWIFT_RELEASE).tar.gz; fi

clean_output:
	rm -r $(OUTPUT_FOLDER);
	
clean_enviroment:
	rm -r $(ENV);
	
build: clean_output compile_src
	
reset: clean_enviroment download_swift build execute_output
	
