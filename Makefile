SRC_FROM_BIN = ../../../../src
OUTPUT_FOLDER = ./output
OUT_FROM_BIN = ../../../../output
ENV = ./enviroment
EXAMPLES = ./examples
SWIFT_RELEASE_VERSION_NUMBER = 5.0
UBUNTU_VERSION_NUMBER = 18
UBUNTU_SUBVERSION_NUMBER = 04
SWIFT_RELEASE = swift-$(SWIFT_RELEASE_VERSION_NUMBER)-RELEASE-ubuntu$(UBUNTU_VERSION_NUMBER).$(UBUNTU_SUBVERSION_NUMBER)
SWIFT_BIN = $(ENV)/$(SWIFT_RELEASE)/usr/bin
TEST_FLAGS =
PROGRAM_FLAGS =

.SILENT: install_swift download_swift prepare_output compile_src clean_output execute_test clean_enviroment execute_imp_zero execute_imp_one release_branch release_imp_zero_branch release_imp_one_branch release_imp_two_branch run_test

all: release_branch download_swift build execute_imp_one

release_branch:
	echo "will set the right branch";
	
release_imp_zero:
	git checkout imp-zero;
	
release_imp_one:
	git checkout imp-one;
	
release_imp_two:
	git checkout imp-two;

compile_test: compile_src execute_test
	
execute_test:
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/test.imp $(TEST_FLAGS);

execute_imp_one: $(EXAMPLES)/imp_one/*.imp
	for file in $^ ; do \
			echo $${file}; \
			./$(OUTPUT_FOLDER)/swimft $${file} $(PROGRAM_FLAGS); \
	done

execute_imp_zero: $(EXAMPLES)/imp_zero/*.imp
	for file in $^ ; do \
			echo $${file}; \
			./$(OUTPUT_FOLDER)/swimft $${file} $(PROGRAM_FLAGS); \
	done

compile_src: prepare_output
	cd $(SWIFT_BIN) && \
	./swiftc -o $(OUT_FROM_BIN)/swimft $(SRC_FROM_BIN)/main.swift \
	$(SRC_FROM_BIN)/lib/**/*.swift \
	$(SRC_FROM_BIN)/lib/**/**/*.swift \
	$(SRC_FROM_BIN)/lib/**/**/**/*.swift;

prepare_output:
	if [ ! -d $(OUTPUT_FOLDER) ]; \
	then mkdir $(OUTPUT_FOLDER); fi

install_swift:
	if [ ! -d $(ENV) ]; \
	then \
		sudo apt-get install clang libcurl4 libcurl4-openssl-dev; fi

download_swift: install_swift
	if [ ! -d $(ENV) ]; \
	then \
		mkdir $(ENV); \
		cd $(ENV) && \
		wget https://swift.org/builds/swift-$(SWIFT_RELEASE_VERSION_NUMBER)-release/ubuntu$(UBUNTU_VERSION_NUMBER)$(UBUNTU_SUBVERSION_NUMBER)/swift-$(SWIFT_RELEASE_VERSION_NUMBER)-RELEASE/$(SWIFT_RELEASE).tar.gz && \
		tar -xvzf $(SWIFT_RELEASE).tar.gz && \
		rm $(SWIFT_RELEASE).tar.gz; fi

clean_output:
	if [ -d $(OUTPUT_FOLDER) ]; \
	then \
		rm -r $(OUTPUT_FOLDER); fi

clean_enviroment:
	if [ -d $(ENV) ]; \
	then \
		rm -r $(ENV); fi

build: clean_output compile_src

reset: clean_enviroment download_swift build
