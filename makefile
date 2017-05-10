build:
	dub build
clean:
	rm ./test/unit/*.out ; rm ./test/unit/*.c ; dub clean
tst:
	./test/test.sh ./test/unit/ ./
run:
	dub run
