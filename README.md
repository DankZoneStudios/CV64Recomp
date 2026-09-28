# Castlevania 64: Recompiled

A work-in-progress static recompilation of **Castlevania 64** for modern
platforms.

This repository is based on
[RevoSucks/CV64Recomp](https://github.com/RevoSucks/CV64Recomp) and extends
that work with a reproducible game-code generation pipeline, build fixes,
runtime fixes, and frontend improvements.

## Status

The project currently builds and runs on Windows.

This is still a work in progress. Compatibility, accuracy, features, and build
support may change as development continues.

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
