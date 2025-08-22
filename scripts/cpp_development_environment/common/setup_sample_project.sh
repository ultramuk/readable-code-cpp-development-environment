#!/bin/bash

set -euo pipefail

# This script sets up a basic C++ sample project in the user's home directory.

# Get the directory of the currently executing script
SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common OS-agnostic utilities
# shellcheck source=./utilities.sh
source "$SCRIPT_DIRECTORY/utilities.sh"

log_info "📁 Creating sample C++ project..."

PROJECT_DIRECTORY="$HOME/cpp-sample"
SOURCE_DIRECTORY="$PROJECT_DIRECTORY/src"
BUILD_DIRECTORY="$PROJECT_DIRECTORY/build"

if [[ -d "$PROJECT_DIRECTORY" ]]; then
  log_warning "⚠️ Directory $PROJECT_DIRECTORY already exists."
  log_warning "   Contents may be overwritten."
fi

# Create all necessary directories
mkdir -p "$SOURCE_DIRECTORY"
mkdir -p "$BUILD_DIRECTORY"

# Create the CMakeLists.txt file in the project's root
cat <<EOF >"$PROJECT_DIRECTORY/CMakeLists.txt"
cmake_minimum_required(VERSION 3.20)
project(HelloWorld LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_BUILD_TYPE Debug)
add_executable(hello_world src/main.cpp)
EOF

# Create the main C++ source file
cat <<EOF >"$SOURCE_DIRECTORY/main.cpp"
#include <cstdint>
#include <iostream>

auto main() -> int32_t {
    int32_t x = 42;
    int32_t y = x * 2;
    std::cout << "Hello, Modern C++! y = " << y << std::endl;
    return 0;
}
EOF

log_info "🔨 Running CMake configure & build in '$BUILD_DIRECTORY'..."
# Configure the project from the source directory, generating the build system in the build directory.
# Then, build the project.
handle_critical_command "cmake -S \"$PROJECT_DIRECTORY\" -B \"$BUILD_DIRECTORY\" && cmake --build \"$BUILD_DIRECTORY\"" "Build failed. Please check CMake and compiler installation"

log_info "✅ Sample project built successfully!"
echo ""
log_info "🚀 Running executable:"
echo "------------------------"
"$BUILD_DIRECTORY/hello_world"
echo "------------------------"
