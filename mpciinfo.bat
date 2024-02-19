@echo off
if not exist build\NUL mkdir build
jwasm -nologo -mz -Sg -Fl=build\ -Fo=build\pciinfo.exe pciinfo.asm
