CC = mpicc
CXX = mpic++
CFLAGS = -Wall -Wextra -g
PROG_NAME = psort
NP = 4

SEED = 0x1234abcd
SIZE = 2000000


all:	main

main:	main.o 
	$(CXX) $(CFLAGS) -o $(PROG_NAME) $^ -lrt

%.o:	%.cc
	$(CXX) $(CFLAGS) -c $<


run: clean all
	clear
	mpirun -np $(NP) $(PROG_NAME) $(SEED) $(SIZE)

debug: clean all
	clear
	mpirun -np $(NP) xterm -hold -e gdb -ex run --args $(PROG_NAME) $(SEED) $(SIZE)
	
run_again:
	clear
	mpirun -np $(NP) $(PROG_NAME) $(SEED) $(SIZE)

clean:
	rm -f *o
