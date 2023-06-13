# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(raudio_library VERSION 0.0.1 LANGUAGES C)

add_library(raudio SHARED
  "raudio.c"
)

set_target_properties(raudio PROPERTIES
  PUBLIC_HEADER raudio.h
  OUTPUT_NAME "raudio"
)

target_compile_definitions(raudio PUBLIC DART_SHARED_LIB)
