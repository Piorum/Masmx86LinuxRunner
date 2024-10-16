#!/bin/bash

# Usage: ./makeasm.sh /path/to/your_program.asm

# Hiding unrelated wine error
export WINEDEBUG=-hid

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/filename.asm"
    exit 1
fi

ASMFILE="$1"

# Check if the file exists
if [ ! -f "$ASMFILE" ]; then
    echo "File $ASMFILE does not exist."
    exit 1
fi

# Get base name and directory
BASENAME=$(basename "${ASMFILE%.*}")
ASM_DIR=$(dirname "$ASMFILE")

# Set the path to MASM tools under Wine
MASM_PATH="$HOME/.wine/drive_c/masm32/bin"
MASM_LIB_PATH="$HOME/.wine/drive_c/masm32/lib"

# Convert paths to Windows format
WIN_ASMFILE=$(winepath -w "$ASMFILE")
WIN_ASM_DIR=$(winepath -w "$ASM_DIR")
WIN_OBJFILE="$WIN_ASM_DIR\\$BASENAME.obj"
WIN_EXEFILE="$WIN_ASM_DIR\\$BASENAME.exe"
WIN_LIBPATH=$(winepath -w "$MASM_LIB_PATH")
WIN_IRVINE_LIBPATH="C:\\Irvine"

# Compile the .asm file to .obj file in the same directory
echo "Compiling $ASMFILE..."
wine "$MASM_PATH/ml.exe" /c /coff /Zi /Fo"$WIN_OBJFILE" "$WIN_ASMFILE" > compile_output.txt 2>&1
compile_status=$?

if [ $compile_status -ne 0 ]; then
    echo "Compilation failed."
    cat compile_output.txt
    exit 1
fi

# Check if the object file was created
OBJFILE="$ASM_DIR/$BASENAME.obj"
if [ ! -f "$OBJFILE" ]; then
    echo "Object file $OBJFILE was not created."
    exit 1
fi

# Link the object file to create an executable in the same directory
echo "Linking $BASENAME.obj..."
wine "$MASM_PATH/link.exe" /VERBOSE /SUBSYSTEM:CONSOLE /OUT:"$WIN_EXEFILE" /LIBPATH:"$WIN_LIBPATH" /LIBPATH:"$WIN_IRVINE_LIBPATH" "$WIN_OBJFILE" Irvine32.lib kernel32.lib user32.lib > link_output.txt 2>&1
link_status=$?

if [ $link_status -ne 0 ]; then
    echo "Linking failed."
    cat link_output.txt
    exit 1
fi

# Check if the executable was created
EXEFILE="$ASM_DIR/$BASENAME.exe"
if [ ! -f "$EXEFILE" ]; then
    echo "Executable $EXEFILE was not created."
    exit 1
fi

# Run the executable via Wine
echo "Running $BASENAME.exe..."
wine "$EXEFILE"

exit 0