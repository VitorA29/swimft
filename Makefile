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

.SILENT: install_swift download_swift prepare_output compile_src clean_output execute_test clean_enviroment execute_imp_zero execute_imp_one release_branch release_imp_zero_branch release_imp_one_branch release_imp_two_branch

all: release_branch download_swift build execute_imp_one

release_branch:
	echo "will set the right branch";
	
release_imp_zero_branch:
	git checkout imp-zero;
	
release_imp_one_branch:
	git checkout imp-one;
	
release_imp_two_branch:
	git checkout imp-two;

execute_test: compile_src
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/test.imp $(TEST_FLAGS);

execute_imp_one:
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_one/simple_test.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_one/test_reference.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_one/test_assign_need_block.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_one/test_double_block.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_one/test_cons.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_one/test_multi_variable_block.imp;

execute_imp_zero:
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/simple_test.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/loop_test.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/conditional_test.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/invalid_operation_automaton-Boo.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/invalid_operation_automaton-Num.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/invalid_operation_parser.imp;
	./$(OUTPUT_FOLDER)/swimft $(EXAMPLES)/imp_zero/fibonacci.imp;

compile_src: prepare_output
	cd $(SWIFT_BIN) && \
	./swiftc -o $(OUT_FROM_BIN)/swimft $(SRC_FROM_BIN)/main.swift $(SRC_FROM_BIN)/lib/**/*.swift;

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
