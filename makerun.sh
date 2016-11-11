#!/bin/bash

name=$1

if [[ -n "$name" ]]; then
	echo "./dasm.exe $name.asm -o$name.bin && ./emu/xvic.exe $name.bin"
	./dasm.exe $name.asm -o$name.bin && ./emu/xvic.exe $name.bin
else
	echo "./makerun.sh \${project_name}"
fi
