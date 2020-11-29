all:
	dasm screenobjects.asm -f3 -v0 -ocart.bin -lcart.lst -scart.sym
run: all
	stella cart.bin
clean: 
	rm cart.bin cart.lst cart.sym
