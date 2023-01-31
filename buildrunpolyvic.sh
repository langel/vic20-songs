#!/bin/bash

./dasm.exe polyvic.asm -opolyvic.prg
../SDL2VICE-3.6.1-win64/xvic.exe -autostart polyvic.prg -sdlaspectmode 2
