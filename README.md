# LuaCMake

## Table of Contents

* [Summary](#summary)
* [Tested platforms and C toolchains](#tested-platforms-and-c-toolchains)
* [Usage](#usage)

## Summary

**LuaCMake** provides a way to install [Lua](https://www.lua.org) on multiple platforms, and multiple C toolchains, throughout the powerful software build system [CMake](https://cmake.org). ``LuaCMake`` allows users with limited C/C++ skills to build ``Lua`` directly from the source code and install it on a target machine by the use of ``cmake``, alongside a C compiler toolchain installed.

## Tested platforms and C toolchains

At the moment, ``LuaCMake`` has been tested to build and install different versions of Lua on the following operating systems and C compiler toolchains:

|            | Windows       | Ubuntu | macOS                                               |
|---         |---            |---     |---                                                           |
|Toolchain    | Visual Studio C/C++ build tools<br>[![VS workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-visual-studio-lua-install.yaml/badge.svg)](./.github/workflows/windows-visual-studio-lua-install.yaml) | GCC + GNU Make from Ubuntu<br>[![Ubuntu workflow](https://github.com/Blequi/LuaCMake/actions/workflows/ubuntu-lua-install.yaml/badge.svg)](./.github/workflows/ubuntu-lua-install.yaml)           | Apple Clang + GNU Make from macOS<br>[![macOS workflow](https://github.com/Blequi/LuaCMake/actions/workflows/macos-lua-install.yaml/badge.svg)](./.github/workflows/macos-lua-install.yaml)           |
|            | clang-cl + Ninja<br>[![clang-cl workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-clang-cl-lua-install.yaml/badge.svg)](./.github/workflows/windows-clang-cl-lua-install.yaml)                           |      |      |
|            | GCC + GNU Make from [MSYS2](https://www.msys2.org)<br>[![MSYS2 workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-msys2-lua-install.yaml/badge.svg)](./.github/workflows/windows-msys2-lua-install.yaml)                           |      |      |
|            | Clang + GNU Make from [MSYS2](https://www.msys2.org)<br>[![MSYS2 workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-msys2-lua-install.yaml/badge.svg)](./.github/workflows/windows-msys2-lua-install.yaml)        |      |      |
|            | GCC + GNU Make from [MinGW](https://sourceforge.net/projects/mingw)<br>[![MinGW workflow](https://github.com/Blequi/LuaCMake/actions/workflows/windows-mingw-lua-install.yaml/badge.svg)](./.github/workflows/windows-mingw-lua-install.yaml)         |      |      |

## Usage

Read the [wiki](https://github.com/Blequi/LuaCMake/wiki) for detailed instructions of how to use ``LuaCMake`` in order to install Lua.
