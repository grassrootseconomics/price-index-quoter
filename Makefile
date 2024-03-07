.PHONY: test build

test:
	forge test -vvv

build:
	forge build -C src -o build --use 0.8.24 --evm-version istanbul --extra-output metadata --skip test script