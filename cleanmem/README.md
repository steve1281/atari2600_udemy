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

OR

* wget  https://github.com/dasm-assembler/dasm/archive/2.20.14.1.tar.gz
* tar xzvf 2.20.14.1.tar.gz
* cd dasm-2.20.14.1
* make

```
~/projects/dasm/dasm-2.20.14.1$ ./bin/dasm 
DASM 2.20.14.1
Copyright (c) 1988-2020 by the DASM team.
...
```
Finally, copy to the user local binary folder:

* sudo mv ./bin/dasm /usr/local/bin/.

```
Next, we need a copy of Stella
link: https://stella-emu.github.io/downloads.html

Going to get "Binary 64-bit DEB for Ubuntu 20.04" 
So that fails. incompatible?
Err.
Check my linux version?

~/projects/stella$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04 LTS
Release:	20.04
Codename:	focal

So... that not it.

Try this: sudo apt-get install -y stella

That worked.
```


# Lets build/run

* cd ~/projects/atari2600_udemy/cleanmem/
* dasm cleanmem.asm -f3 -v0 -ocart.bin
* stella cart.bin
* play with debugger as per lesson.


