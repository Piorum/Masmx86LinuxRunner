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

# Create a directory in Wine's C: drive for object files and executables
WINE_OBJ_DIR="$HOME/.wine/drive_c/asm"
mkdir -p "$WINE_OBJ_DIR"

# Convert paths to Windows format
WIN_ASMFILE=$(winepath -w "$ASMFILE")
WIN_OBJFILE="C:\\asm\\$BASENAME.obj"
WIN_EXEFILE="C:\\asm\\$BASENAME.exe"
WIN_LIBPATH=$(winepath -w "$MASM_LIB_PATH")
WIN_IRVINE_LIBPATH="C:\\Irvine"

# Compile the .asm file to .obj file in C:\asm\
echo "Compiling $ASMFILE..."
wine "$MASM_PATH/ml.exe" /c /coff /Zi /Fo"$WIN_OBJFILE" "$WIN_ASMFILE" > compile_output.txt 2>&1
compile_status=$?

if [ $compile_status -ne 0 ]; then
    echo "Compilation failed."
    cat compile_output.txt
    exit 1
fi

# Check if the object file was created
if [ ! -f "$WINE_OBJ_DIR/$BASENAME.obj" ]; then
    echo "Object file $WINE_OBJ_DIR/$BASENAME.obj was not created."
    exit 1
fi

# Link the object file to create an executable in C:\asm\
echo "Linking $BASENAME.obj..."
WIN_EXEFILE="C:\\asm\\$BASENAME.exe"
wine "$MASM_PATH/link.exe" /VERBOSE /SUBSYSTEM:CONSOLE /OUT:"$WIN_EXEFILE" /LIBPATH:"$WIN_LIBPATH" /LIBPATH:"$WIN_IRVINE_LIBPATH" "$WIN_OBJFILE" Irvine32.lib kernel32.lib user32.lib > link_output.txt 2>&1
link_status=$?

if [ $link_status -ne 0 ]; then
    echo "Linking failed."
    cat link_output.txt
    exit 1
fi

# Check if the executable was created
if [ ! -f "$WINE_OBJ_DIR/$BASENAME.exe" ]; then
    echo "Executable $WINE_OBJ_DIR/$BASENAME.exe was not created."
    exit 1
fi

# Run the executable via Wine
echo "Running $BASENAME.exe..."
wine "$WINE_OBJ_DIR/$BASENAME.exe"

exit 0
