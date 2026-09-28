# Building Castlevania 64: Recompiled

This document describes the build process currently used and tested for
Castlevania 64: Recompiled.

The project does not distribute the Castlevania 64 ROM or generated game code.
You must provide your own original North American Castlevania 64 ROM in `.z64`
format.

## 1. Clone the repository

Clone the repository recursively so all required submodules are initialized:

~~~bash
git clone --recursive <repository-url>
cd CV64Recomp
~~~

If the repository was cloned without `--recursive`, initialize the submodules
with:

~~~bash
git submodule update --init --recursive
~~~

## 2. Generate the game code

Generation is currently tested under Linux/WSL.

### Linux/WSL prerequisites

The generation process requires:

- Python 3 with `venv`
- CMake
- Ninja
- Git
- Make
- Clang
- LLD
- GNU Binutils
- MIPS GNU Binutils (`mips-linux-gnu-*`)

On Ubuntu, the required system packages can be installed with:

~~~bash
sudo apt update
sudo apt install python3 python3-venv cmake ninja-build git make clang lld binutils binutils-mips-linux-gnu
~~~

Python dependencies used by the CV64 decompilation build are installed into a
project-local virtual environment automatically by the bootstrap script.

### Required ROM

Use an original North American Castlevania 64 ROM in `.z64` format.

Expected SHA-1:

~~~text
989a28782ed6b0bc489a1bbbd7bec355d8f2707e
~~~

The generation script verifies the ROM before using it.

### Run the generator

From the root of the repository:

~~~bash
./tools/generate.sh /path/to/castlevania.z64
~~~

The generator:

1. verifies the original ROM;
2. prepares the pinned CV64 decompilation build environment;
3. decompresses and verifies the ROM;
4. builds and verifies the CV64 ELF used for recompilation;
5. builds N64Recomp and RSPRecomp;
6. generates the recompiled game code; and
7. generates the RSP code.

On success, the important generated inputs include:

~~~text
cv64.decompressed.z64
cv64.decompressed.us.elf
RecompiledFuncs/
rsp/n_aspMain.cpp
~~~

These files are generated locally and are intentionally excluded from Git.

## 3. Build on Windows

The Windows build has been tested with:

- Windows 10/11 x64
- Visual Studio 2022
- LLVM/Clang (`clang-cl`) for the Windows build
- A standalone LLVM installation with MIPS target support for the project patches
- CMake
- Ninja

Run the following commands from a Visual Studio 2022 x64 developer environment.

The patch build requires a Clang/LLD installation with MIPS target support.
Visual Studio's bundled LLVM may not include the required MIPS backend options.
If standalone LLVM is installed in `C:\Program Files\LLVM`, configure it
explicitly with `PATCHES_C_COMPILER` and `PATCHES_LD` as shown below.

Configure a Release build:

~~~cmd
cmake -S . -B out/build/release -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DPATCHES_C_COMPILER="C:/Program Files/LLVM/bin/clang.exe" -DPATCHES_LD="C:/Program Files/LLVM/bin/ld.lld.exe"
~~~

Build the executable:

~~~cmd
cmake --build out/build/release --target CV64Recompiled
~~~

CMake also builds the project patches and copies the required runtime assets and
DLLs into the output directory.

The resulting executable is:

~~~text
out/build/release/CV64Recompiled.exe
~~~

## Regenerating after game-code changes

Run the generator again when the decompilation/recompilation inputs need to be
regenerated:

~~~bash
./tools/generate.sh /path/to/castlevania.z64
~~~

Then rebuild `CV64Recompiled` on Windows.

Changes to the project's patch sources are handled by the CMake dependency
chain and do not require running the generator again.

## Cleaning generated files

The generated game inputs and normal CMake build directories are ignored by
Git. They can be regenerated from the supported original ROM and the repository
sources.

Do not commit or distribute ROM files, decompressed ROM files, generated
ROM-derived game code, or other copyrighted game data.
