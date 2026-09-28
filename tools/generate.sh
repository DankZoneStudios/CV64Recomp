#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

EXPECTED_ROM_SHA1="989a28782ed6b0bc489a1bbbd7bec355d8f2707e"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/castlevania.z64" >&2
    echo >&2
    echo "Requires an original North American Castlevania 64 ROM in .z64 format." >&2
    exit 1
fi

ROM_PATH="$1"

if [[ ! -f "${ROM_PATH}" ]]; then
    echo "Error: ROM file not found:" >&2
    echo "  ${ROM_PATH}" >&2
    exit 1
fi

echo "===== Castlevania 64 Recomp generation ====="
echo "Project: ${ROOT_DIR}"
echo

echo "Validating original ROM..."

ROM_SHA1="$(sha1sum "${ROM_PATH}" | awk '{print $1}')"

if [[ "${ROM_SHA1}" != "${EXPECTED_ROM_SHA1}" ]]; then
    echo "Error: unsupported ROM." >&2
    echo "Expected SHA-1: ${EXPECTED_ROM_SHA1}" >&2
    echo "Found SHA-1:    ${ROM_SHA1}" >&2
    echo >&2
    echo "Use the original North American Castlevania 64 ROM in .z64 format." >&2
    exit 1
fi

echo "Original ROM SHA-1 verified."

CV64_DIR="${CV64_DIR:-${ROOT_DIR}/lib/cv64}"
REQUIRED_CV64_BASE="20f79e3de71f871df0829c448882765f86336c9e"

if [[ ! -d "${CV64_DIR}/.git" && ! -f "${CV64_DIR}/.git" ]]; then
    echo "Error: CV64 decomp submodule is not initialized:" >&2
    echo "  ${CV64_DIR}" >&2
    exit 1
fi

if ! git -C "${CV64_DIR}" merge-base --is-ancestor "${REQUIRED_CV64_BASE}" HEAD 2>/dev/null; then
    CV64_HEAD="$(git -C "${CV64_DIR}" rev-parse HEAD)"
    echo "Error: the CV64 decomp source does not contain the required base." >&2
    echo "Required ancestor: ${REQUIRED_CV64_BASE}" >&2
    echo "Current HEAD:      ${CV64_HEAD}" >&2
    exit 1
fi

echo "CV64 decomp source verified."

CV64_BOOTSTRAP="${CV64_DIR}/tools/bootstrap-build.sh"

if [[ ! -f "${CV64_BOOTSTRAP}" ]]; then
    echo "Error: CV64 bootstrap script not found:" >&2
    echo "  ${CV64_BOOTSTRAP}" >&2
    exit 1
fi

echo
echo "===== Preparing CV64 decomp build ====="
bash "${CV64_BOOTSTRAP}" "${ROM_PATH}"

CV64_BUILD_DIR="${CV64_DIR}/.recomp-build"
CV64_PYTHON="${CV64_DIR}/.venv-build/bin/python"

if [[ ! -x "${CV64_PYTHON}" ]]; then
    echo "Error: CV64 build Python was not created by the bootstrap:" >&2
    echo "  ${CV64_PYTHON}" >&2
    exit 1
fi

echo
echo "===== Configuring CV64 decomp build ====="
cmake \
    -S "${CV64_DIR}" \
    -B "${CV64_BUILD_DIR}" \
    -G Ninja \
    -Dcompress=OFF \
    -DPython_EXECUTABLE="${CV64_PYTHON}"

echo
echo "===== Building CV64 decomp ELF ====="
cmake --build "${CV64_BUILD_DIR}" --target castlevania

CV64_ELF="${CV64_BUILD_DIR}/castlevania"
EXPECTED_CV64_BINARY_SHA256="8f888e72907e4c932afda0db3ec2e2940c90ebc17a93eac95b6df06a8d578ffe"
EXPECTED_CV64_RELOCATION_SECTIONS=174
CV64_BINARY="${CV64_BUILD_DIR}/castlevania.recomp.bin"

if [[ ! -f "${CV64_ELF}" ]]; then
    echo "Error: CV64 decomp ELF was not produced:" >&2
    echo "  ${CV64_ELF}" >&2
    exit 1
fi

echo
echo "Verifying CV64 decomp ELF..."

CV64_RELOCATION_SECTIONS="$(readelf -SW "${CV64_ELF}" | grep -c '\.rel\.' || true)"

if [[ "${CV64_RELOCATION_SECTIONS}" -ne "${EXPECTED_CV64_RELOCATION_SECTIONS}" ]]; then
    echo "Error: CV64 decomp ELF has an unexpected relocation-section count." >&2
    echo "Expected: ${EXPECTED_CV64_RELOCATION_SECTIONS}" >&2
    echo "Found:    ${CV64_RELOCATION_SECTIONS}" >&2
    exit 1
fi

mips-linux-gnu-objcopy -O binary "${CV64_ELF}" "${CV64_BINARY}"
CV64_BINARY_SHA256="$(sha256sum "${CV64_BINARY}" | awk '{print $1}')"

if [[ "${CV64_BINARY_SHA256}" != "${EXPECTED_CV64_BINARY_SHA256}" ]]; then
    echo "Error: CV64 decomp ELF loadable image failed SHA-256 verification." >&2
    echo "Expected: ${EXPECTED_CV64_BINARY_SHA256}" >&2
    echo "Found:    ${CV64_BINARY_SHA256}" >&2
    exit 1
fi

rm -f "${CV64_BINARY}"

echo "CV64 decomp ELF verified (${EXPECTED_CV64_RELOCATION_SECTIONS} relocation sections)."
echo "CV64 loadable image SHA-256 verified."

CV64_DECOMPRESSED_ROM="${CV64_DIR}/baserom_uncompressed.z64"
PARENT_DECOMPRESSED_ROM="${ROOT_DIR}/cv64.decompressed.z64"
PARENT_DECOMP_ELF="${ROOT_DIR}/cv64.decompressed.us.elf"
EXPECTED_DECOMPRESSED_SHA1="c176c2493d90e12d0a2b6873cfcbc611a9bea245"

if [[ ! -f "${CV64_DECOMPRESSED_ROM}" ]]; then
    echo "Error: decompressed CV64 ROM was not produced:" >&2
    echo "  ${CV64_DECOMPRESSED_ROM}" >&2
    exit 1
fi

echo
echo "===== Installing generated game inputs ====="

cp "${CV64_DECOMPRESSED_ROM}" "${PARENT_DECOMPRESSED_ROM}"
cp "${CV64_ELF}" "${PARENT_DECOMP_ELF}"

COPIED_ROM_SHA1="$(sha1sum "${PARENT_DECOMPRESSED_ROM}" | awk '{print $1}')"

if [[ "${COPIED_ROM_SHA1}" != "${EXPECTED_DECOMPRESSED_SHA1}" ]]; then
    echo "Error: copied decompressed ROM failed SHA-1 verification." >&2
    echo "Expected: ${EXPECTED_DECOMPRESSED_SHA1}" >&2
    echo "Found:    ${COPIED_ROM_SHA1}" >&2
    exit 1
fi

if ! cmp -s "${CV64_ELF}" "${PARENT_DECOMP_ELF}"; then
    echo "Error: copied CV64 ELF does not match the generated ELF." >&2
    exit 1
fi

echo "Generated game inputs installed and verified."

RECOMP_SOURCE_DIR="${ROOT_DIR}/lib/N64ModernRuntime/N64Recomp"
RECOMP_BUILD_DIR="${ROOT_DIR}/out/build/recompiler-tools"

echo
echo "===== Configuring recompilation tools ====="
cmake \
    -S "${RECOMP_SOURCE_DIR}" \
    -B "${RECOMP_BUILD_DIR}" \
    -G Ninja

echo
echo "===== Building recompilation tools ====="
cmake --build "${RECOMP_BUILD_DIR}" --target N64RecompCLI RSPRecomp

N64RECOMP="${RECOMP_BUILD_DIR}/N64Recomp"
RSPRECOMP="${RECOMP_BUILD_DIR}/RSPRecomp"

if [[ ! -x "${N64RECOMP}" || ! -x "${RSPRECOMP}" ]]; then
    echo "Error: recompilation tools were not produced." >&2
    exit 1
fi

echo
echo "===== Generating recompiled game code ====="
rm -rf "${ROOT_DIR}/RecompiledFuncs"
mkdir -p "${ROOT_DIR}/RecompiledFuncs"

(
    cd "${ROOT_DIR}"
    "${N64RECOMP}" cv64.toml
)

RECOMPILED_FILE_COUNT="$(find "${ROOT_DIR}/RecompiledFuncs" -maxdepth 1 -type f | wc -l)"

if [[ "${RECOMPILED_FILE_COUNT}" -ne 164 ]]; then
    echo "Error: unexpected RecompiledFuncs file count." >&2
    echo "Expected: 164" >&2
    echo "Found:    ${RECOMPILED_FILE_COUNT}" >&2
    exit 1
fi

echo "Generated ${RECOMPILED_FILE_COUNT} recompiled game-code files."

echo
echo "===== Generating RSP code ====="
rm -rf "${ROOT_DIR}/rsp"
mkdir -p "${ROOT_DIR}/rsp"

(
    cd "${ROOT_DIR}"
    "${RSPRECOMP}" aspMain.toml
)

RSP_OUTPUT="${ROOT_DIR}/rsp/n_aspMain.cpp"
EXPECTED_RSP_SHA256="35ca861f76d5c419391d2ab8d49fe421a2f0ec3bccff3da959dbf8b4568390ff"

if [[ ! -f "${RSP_OUTPUT}" ]]; then
    echo "Error: RSPRecomp did not produce n_aspMain.cpp." >&2
    exit 1
fi

RSP_SHA256="$(sha256sum "${RSP_OUTPUT}" | awk '{print $1}')"

if [[ "${RSP_SHA256}" != "${EXPECTED_RSP_SHA256}" ]]; then
    echo "Error: generated RSP code failed SHA-256 verification." >&2
    echo "Expected: ${EXPECTED_RSP_SHA256}" >&2
    echo "Found:    ${RSP_SHA256}" >&2
    exit 1
fi

echo "RSP output SHA-256 verified."

echo
echo "===== Generation complete ====="
echo "Generated:"
echo "  cv64.decompressed.z64"
echo "  cv64.decompressed.us.elf"
echo "  RecompiledFuncs/"
echo "  rsp/n_aspMain.cpp"
