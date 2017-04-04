build:
	dub build
clean:
	rm ./test/tests/unit/*.out ; rm ./test/tests/unit/*.c ; dub clean
tst:
	./test/tests/test.sh
run:
	dub run
