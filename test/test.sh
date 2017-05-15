export ALEPH_LIB=$3
find $1/*.al | xargs -n1 $2/alephc
# find $1/*.c | xargs -n1 -I X gcc -oX.out -O0 X
# find $1/*.out | xargs -n1 sh -c
