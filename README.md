# Masmx86LinuxRunner
bash script to compile, link, and run MASM32 with Irvine32 libraries under Linux. Requires some setup.

Step (1): Setup Wine Directory

Step (2): Install MASM32 SDK from http://www.masm32.com/ using wine

Step (3): Install Irvine32.lib to "C:\Irvine\Irvine32.lib"

Step (4): Create an intermediate folder for .obj and .exe files, "C:\asm" by default

The script should now be runnable, Ex: "./makeasm.sh /path/to/program.asm"
