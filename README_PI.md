# Setting up software on a respberry pi

I use a pi4; but the instructions should port OK.

# Install stella

```
sudo apt-get install stella
```

# Install dasm

I could not find an apt-get solution, so I built it instead:

```
git clone https://github.com/dasm-assembler/dasm.git
cd dasm
make
cd ..
mv ~/projects/dasm/bin/dasm /usr/local/bin/dasm
```

# Quick check
```
pi@pi4:~/projects $ dasm
DASM 2.20.15-SNAPSHOT
Copyright (c) 1988-2020 by the DASM team.
License GPLv2+: GNU GPL version 2 or later (see file LICENSE).
...
```

# Test/Check

```
pi@pi4:~/projects/udemy $ git clone https://github.com/steve1281/atari2600_udemy.git
Cloning into 'atari2600_udemy'...
remote: Enumerating objects: 108, done.
remote: Counting objects: 100% (108/108), done.
remote: Compressing objects: 100% (88/88), done.
remote: Total 108 (delta 37), reused 83 (delta 19), pack-reused 0
Receiving objects: 100% (108/108), 34.91 KiB | 893.00 KiB/s, done.
Resolving deltas: 100% (37/37), done.
pi@pi4:~/projects/udemy $ cd atari2600_udemy/
pi@pi4:~/projects/udemy/atari2600_udemy $ ls
cleanmem  horizontalpos           include    playfield_exercise  README_MAC.md  screenobjects            template
colorbg   horizontalpos_exercise  playfield  rainbow             README.md      screenobjects_score_fix  verticalpos
pi@pi4:~/projects/udemy/atari2600_udemy $ pwd
/home/pi/projects/udemy/atari2600_udemy
pi@pi4:~/projects/udemy/atari2600_udemy $ cd rainbow
pi@pi4:~/projects/udemy/atari2600_udemy/rainbow $ make run
dasm rainbow.asm -f3 -v0 -ocart.bin -lcart.lst -scart.sym

Complete. (0)
stella cart.bin
pi@pi4:~/projects/udemy/atari2600_udemy/rainbow $ 
```

Worked good.

