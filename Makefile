BIN = ./bin
SRC = ./src
ENV = ./enviroment
SWIFT_BIN = ./swift-5.0-RELEASE-ubuntu18.04/usr/bin
TAR_FILE_NAME= swift-5.0-RELEASE-ubuntu18.04.tar.gz

.SILENT: setup_swift

setup_swift: install
	if [ ! -d $(ENV) ]; \
	then \
		mkdir $(ENV); \
		cd $(ENV) && \
		wget https://swift.org/builds/swift-5.0-release/ubuntu1804/swift-5.0-RELEASE/swift-5.0-RELEASE-ubuntu18.04.tar.gz && \
		tar -xvzf $(TAR_FILE_NAME) && \
		rm $(TAR_FILE_NAME) && \
		cd $(SWIFT_BIN) && \
		export PATH=pwd:$PATH; fi
install:
	sudo apt-get install clang libicu-dev;
