build:
	dub build
clean:
	rm ./test/tests/unit/*.c
	rm ./test/tests/unit/*.out
	dub clean
tst:
	./test/tests/test.sh
run:
	dub run
