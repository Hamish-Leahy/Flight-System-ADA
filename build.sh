#!/bin/bash
# Build script for Ada Flight Control System

echo "Building Ada Flight Control System..."
echo ""

# Build main program
echo "Building main program..."
gprbuild -P ada_project.gpr

if [ $? -eq 0 ]; then
    echo ""
    echo "Build successful!"
    echo "Run with: ./bin/main"
else
    echo ""
    echo "Build failed!"
    exit 1
fi
