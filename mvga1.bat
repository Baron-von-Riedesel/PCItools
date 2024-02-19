@echo off
rem pestub, patchpe are in HXDEV
if not exist build\NUL mkdir build
jwasm -nologo -pe -Sg -Fl=build\ -Fo=build\ vga1.asm
pestub -n -q build\vga1.exe loadpe.bin
patchpe -x -s:8192 -h:0 build\vga1.exe
