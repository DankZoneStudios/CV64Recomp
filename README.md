# Castlevania 64: Recompiled (CV64Recomp)

A high-performance, native PC port and static recompilation of **Castlevania 64** for modern platforms. 

Unlike alternative builds that suffer from emulation lag, crashes, and severe frame drops, this project focuses on complete engine stability, native PC rendering optimization, and modern feature integration.

This repository is based on
[RevoSucks/CV64Recomp](https://github.com/RevoSucks/CV64Recomp) and extends
that work with a reproducible game-code generation pipeline, build fixes,
runtime fixes, and frontend improvements.

## Key Features & Performance Enhancements
* **Unlocked Framerates:** Supports true 60 FPS, 120 FPS, and higher uncapped display refresh rates without breaking internal game speed or animation logic.
* **Stable Widescreen Support:** Full widescreen layout compatibility with an expanded camera frustum, completely eliminating the background object flickering common in emulation hacks.
* **Zero Performance Slowdowns:** Upgraded rendering pipelines to completely eliminate emulation-heavy frame drops in the Altar zones and introductory levels.
* **Custom Modding & Texture Packs:** Native support for loading custom Castlevania 64 texture packs and community graphics modifications.

## Status

The project currently builds and runs on Windows.

This is still a work in progress. Compatibility, accuracy, features, and build
support may change as development continues.

## Modding & Texture Pack Installation

This build features full compatibility with custom Castlevania 64 texture packs and community graphics mods via the integrated desktop launcher:

1. Launch the game executable to open the built-in mod configuration interface.
2. Click the **Open Mods Folder** button inside the launcher menu to instantly open the correct directory on your PC.
3. Drop your custom texture packs (unzipped asset folders) directly into this location.
4. Select your newly added texture pack from the launcher list, toggle it to **Enabled**, and start the game to play with high-definition visuals.

## Building

See [BUILDING.md](BUILDING.md) for the complete build instructions.

Building from source requires an original North American Castlevania 64 ROM in
`.z64` format. The ROM is used locally to generate the recompilation inputs and
is not included with this repository.

No Castlevania 64 ROM or generated ROM-derived game code is distributed by this
project.

## Credits

This project builds on the work of:

- [RevoSucks/CV64Recomp](https://github.com/RevoSucks/CV64Recomp)
- [RevoSucks/cv64](https://github.com/RevoSucks/cv64)
- [N64Recomp](https://github.com/N64Recomp/N64Recomp)
- [N64ModernRuntime](https://github.com/N64Recomp/N64ModernRuntime)
- [RT64](https://github.com/rt64/rt64)
- [RecompFrontend](https://github.com/N64Recomp/RecompFrontend)

Additional dependency modifications required by this project are maintained in
the corresponding DankZoneStudios forks referenced by the Git submodules.

## License

This repository is distributed under the GNU General Public License v3.0.
See [COPYING](COPYING) for the full license text.

This is a modified version of the upstream CV64Recomp project. Modifications
include build/reproducibility work, dependency fixes, runtime fixes, and
frontend changes made for this continuation of the project.
