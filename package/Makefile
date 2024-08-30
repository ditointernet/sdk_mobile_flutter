login:
	buf registry login

pull:
	buf export buf.build/dito/sdk-service -o proto

build:
	buf build
	buf generate proto
