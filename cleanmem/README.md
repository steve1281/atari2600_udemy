# Notes about the cleanmem project

This code is a super clean/simple example of a cartridge bin allowing us
to clean the zero page and exit.

It demonstrates the housecleaning commands that all atari2600 cartridge bins will have.

## building

We need  the tools:
* dasm  - for compiling
* stella - for running and debugging

Also need an editor.  For new users, he recommends vcode. (To be very clear - I don't recommend vcode. Its configuration files for build and execute are way overkill for any simple project. A simple text editor (notepad++ or vim) make a lot more sense for getting started, imho.  Its not like you can run/debug from an IDE anyway.)


also: https://8bitworkshop.com/

## In windows10 environment

```
D:\projects\udemy\atari2600\cleanmem>\bin\dasm cleanmem.asm -f3 -v0 -ocart.bin

Stella - run it.
load cart.bin
press ` to run debugger

````

I am abandoning the windows10 environment development; I will be working in Linux. 

## In Linux.

* get dasm from  https://dasm-assembler.github.io/
* that will land in you ./Downloads
* tar xvf dasm-2.20.14-linux-x64.tar.gz
* sudo mv dasm /usr/local/bin/.
* chmod u+x /usr/local/bin/dasm

bah

wget  https://github.com/dasm-assembler/dasm/archive/2.20.14.1.tar.gz
tar xzvf 2.20.14.1.tar.gz
cd dasm-2.20.14.1
make


