@echo off
rem pestub, patchpe are in HXDEV
if not exist build\NUL mkdir build
jwasm -nologo -pe -Sg -Fl=build\ -Fo=build\ usb1.asm
pestub -n -q build\usb1.exe loadpe.bin
patchpe -x -s:8192 -h:0 build\usb1.exe
