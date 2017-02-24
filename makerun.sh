#!/bin/bash

name=$1

if [[ -n "$name" ]]; then
	echo "./dasm.exe $name.asm -o$name.prg && ./emu/xvic.exe $name.prg"
	./dasm.exe $name.asm -o$name.prg && ./emu/xvic.exe $name.prg
else
	echo "./makerun.sh \${project_name}"
fi
