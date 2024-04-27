# LuaCMake

## Table of Contents

* [Summary](#summary)
* [Tested platforms and C toolchains](#tested-platforms-and-c-toolchains)
* [Usage](#usage)

## Summary

**LuaCMake** provides a way to install [Lua](https://www.lua.org) on multiple platforms (special focus on Windows), and multiple C toolchains, throughout the powerful software build system [CMake](https://cmake.org). ``LuaCMake`` allows users with limited C/C++ skills to build ``Lua`` directly from the source code and install it on a target machine by the use of ``cmake``, alongside a C compiler toolchain installed.

## Tested platforms and C toolchains

At the moment, ``LuaCMake`` has been tested to build and install different versions of Lua on the following operating systems and C compiler toolchains:

|            | Windows 11       | Ubuntu 22.04.3                                               |
|---         |---               |---                                                           |
|Toolchain    | Visual Studio 2022 C/C++ x86/x64 build tools ![VS workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-visual-studio-lua-install.yaml/badge.svg?branch=main) | GCC 11.4.0 + GNU Make 4.3 from Ubuntu ![Ubuntu workflow](https://github.com/Blequi/LuaCMake/actions/workflows/ubuntu-lua-install.yaml/badge.svg?branch=main)           |
|            | GCC 13.2.0 + GNU Make 4.4.1 from [MSYS2](https://www.msys2.org) ![MSYS2 workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-msys2-lua-install.yaml/badge.svg?branch=main)                           |      |
|            | Clang 18.1.4 + GNU Make 4.4.1 from [MSYS2](https://www.msys2.org)  ![MSYS2 workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-msys2-lua-install.yaml/badge.svg?branch=main)        |      |
|            | GCC 6.3.0 + GNU Make 3.82.90 from [MinGW](https://sourceforge.net/projects/mingw)         |      |

## Usage

Read the [wiki](https://github.com/Blequi/LuaCMake/wiki) for detailed instructions of how to use ``LuaCMake`` in order to install Lua.
