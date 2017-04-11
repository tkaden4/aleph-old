build:
	dub build
clean:
	rm ./test/unit/*.out ; rm ./test/unit/*.c ; dub clean
tst:
	./test/test.sh
run:
	dub run
