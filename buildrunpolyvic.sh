#!/bin/bash

./dasm.exe polyvic.asm -opolyvic.prg
../../games/VICE-3.6.1-win64/xvic.exe -autostart polyvic.prg
