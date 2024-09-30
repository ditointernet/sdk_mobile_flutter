login:
	buf registry login

pull:
	buf export buf.build/dito/sdk-service -o proto
	buf export buf.build/protocolbuffers/wellknowntypes -o proto

build:
	buf build
	buf generate proto --include-imports --clean --debug
