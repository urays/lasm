#!/usr/bin/bash
# By urays (urays@foxmail.com)
set -eu

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$(realpath "${SCRIPT_DIR}/..")"

# Check if 'tens' conda environment is activated
if [[ -z "${CONDA_DEFAULT_ENV:-}" || "${CONDA_DEFAULT_ENV:-}" != "tens" ]]; then
    echo "Error: 'tens' conda environment is not activated."
    echo "Please run: conda activate tens"
    exit 1
fi

#-------------------------------------------------------------------------------
BUILD_MODE="Release"
LLVM_REBUILD=false
LLVM_PROJECTS="clang;clang-tools-extra;lld;polly"
LLVM_RUNTIMES="openmp"

#-------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            BUILD_MODE="Debug"
            shift
            ;;
        -r|--release)
            BUILD_MODE="Release"
            shift
            ;;
        -c|--clean)
            LLVM_REBUILD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-d|--debug] [-r|--release] [-c|--clean]"
            echo "Notes:"
            echo "  Uses system clang/clang++ to build the single llvm-build tree."
            echo "  Downstream projects consume third-party/llvm-build directly."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-d|--debug] [-r|--release] [-c|--clean]"
            exit 1
            ;;
    esac
done

#-------------------------------------------------------------------------------
LLVM_COMMIT=7f77ca0dbda4abbf9af06537b2c475f20ccd6007 # llvm 23.0.0
LLVM_SOURCE_DIR="${ROOT_DIR}/third-party/llvm-project"
LLVM_BUILD_DIR="${ROOT_DIR}/third-party/llvm-build"
LLVM_CC="$(command -v clang || true)"
LLVM_CXX="$(command -v clang++ || true)"
LLVM_LINKER=""
LLVM_LINKER_BIN_DIR=""
LLVM_PARALLEL_LINK_JOBS=2

if command -v ld.lld >/dev/null 2>&1; then
    LLVM_LINKER="lld"
else
    LLVM_LLD_CANDIDATE="$(ls -1d /usr/lib/llvm-*/bin/ld.lld 2>/dev/null | sort -V | tail -n1 || true)"
    if [ -n "${LLVM_LLD_CANDIDATE}" ] && [ -x "${LLVM_LLD_CANDIDATE}" ]; then
        LLVM_LINKER="lld"
        LLVM_LINKER_BIN_DIR="$(dirname "${LLVM_LLD_CANDIDATE}")"
    fi
fi

if [ -z "${LLVM_LINKER}" ] && command -v ld.gold >/dev/null 2>&1; then
    LLVM_LINKER="gold"
fi

if [ ! -d "${LLVM_SOURCE_DIR}" ]; then
    git clone https://github.com/llvm/llvm-project.git "${LLVM_SOURCE_DIR}"
fi
echo -e "\e[32m[LLVM_COMMIT] ${LLVM_COMMIT}\e[39m"
cd "${LLVM_SOURCE_DIR}" && git fetch && git checkout "${LLVM_COMMIT}"

#-------------------------------------------------------------------------------
if [ ! -x "${LLVM_CC}" ] || [ ! -x "${LLVM_CXX}" ]; then
    echo -e "\e[31mError: system clang/clang++ were not found.\e[39m"
    echo "Please install clang and clang++ first."
    exit 1
fi

#-------------------------------------------------------------------------------
if [ "${LLVM_REBUILD}" == "true" ]; then
    [ -d "${LLVM_BUILD_DIR}" ] && rm -rf "${LLVM_BUILD_DIR}"
fi

#-------------------------------------------------------------------------------
echo -e "BUILD_MODE: \e[32m${BUILD_MODE}\e[39m"

#-------------------------------------------------------------------------------
LLVM_TARGETS_TO_BUILD="Native;AMDGPU;NVPTX;WebAssembly"
case "$(uname -m)" in
    x86_64|amd64|i686|i386)
        ;;
    *)
        LLVM_TARGETS_TO_BUILD="${LLVM_TARGETS_TO_BUILD};X86"
        ;;
esac

echo -e "LLVM_C_COMPILER: \e[32m${LLVM_CC}\e[39m"
echo -e "LLVM_CXX_COMPILER: \e[32m${LLVM_CXX}\e[39m"
echo -e "LLVM_PROJECTS: \e[32m${LLVM_PROJECTS}\e[39m"
echo -e "LLVM_RUNTIMES: \e[32m${LLVM_RUNTIMES}\e[39m"
echo -e "LLVM_TARGETS_TO_BUILD: \e[32m${LLVM_TARGETS_TO_BUILD}\e[39m"
if [ -n "${LLVM_LINKER}" ]; then
    echo -e "LLVM_USE_LINKER: \e[32m${LLVM_LINKER}\e[39m"
else
    echo -e "\e[33mLLVM_USE_LINKER: system default linker\e[39m"
fi
if [ -n "${LLVM_LINKER_BIN_DIR}" ]; then
    echo -e "LLVM_LINKER_BIN_DIR: \e[32m${LLVM_LINKER_BIN_DIR}\e[39m"
fi
echo -e "LLVM_PARALLEL_LINK_JOBS: \e[32m${LLVM_PARALLEL_LINK_JOBS}\e[39m"

echo -e "LLVM_BUILD_DIR: \e[32m${LLVM_BUILD_DIR}\e[39m"
if [ -n "${LLVM_LINKER_BIN_DIR}" ]; then
    export PATH="${LLVM_LINKER_BIN_DIR}:${PATH}"
fi
CMAKE_ARGS=(
    -DCMAKE_BUILD_TYPE="${BUILD_MODE}"
    -DCMAKE_C_COMPILER="${LLVM_CC}"
    -DCMAKE_CXX_COMPILER="${LLVM_CXX}"
    -DCMAKE_PLATFORM_NO_VERSIONED_SONAME:BOOL=ON
    -DLLVM_ENABLE_PROJECTS="${LLVM_PROJECTS}"
    -DLLVM_ENABLE_RUNTIMES="${LLVM_RUNTIMES}"
    -DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS_TO_BUILD}"
    -DLLVM_ENABLE_ASSERTIONS=ON
    -DLLVM_ENABLE_LLD=OFF
    -DLLVM_BUILD_TOOLS=ON
    -DLLVM_BUILD_UTILS=ON
    -DLLVM_INCLUDE_TOOLS=ON
    -DLLVM_BUILD_LLVM_DYLIB=OFF
    -DLLVM_LINK_LLVM_DYLIB=OFF
    -DCLANG_LINK_CLANG_DYLIB=OFF
    -DLLVM_PARALLEL_LINK_JOBS="${LLVM_PARALLEL_LINK_JOBS}"
    -DLLVM_USE_SPLIT_DWARF=ON
    -DLLVM_ENABLE_BINDINGS=ON
    -DLLVM_ENABLE_Z3_SOLVER=ON
    -DMLIR_ENABLE_BINDINGS_PYTHON=ON
    -DMLIR_ENABLE_CUDA_RUNNER=OFF
    -DMLIR_INCLUDE_TESTS=OFF
    -DOPENMP_ENABLE_LIBOMPTARGET=OFF
    -DPython3_EXECUTABLE="$(which python3)"
    -DPOLLY_BUNDLED_ISL=ON
    -Wno-dev
)

if [ -n "${LLVM_LINKER}" ]; then
    CMAKE_ARGS+=( -DLLVM_USE_LINKER="${LLVM_LINKER}" )
fi

cmake -G Ninja \
    "${LLVM_SOURCE_DIR}/llvm" -B "${LLVM_BUILD_DIR}" \
    "${CMAKE_ARGS[@]}"

ninja -C "${LLVM_BUILD_DIR}" -j "$(nproc)"

LLVM_CONFIG="${LLVM_BUILD_DIR}/bin/llvm-config"
FINAL_CLANG="${LLVM_BUILD_DIR}/bin/clang"
FINAL_CLANGXX="${LLVM_BUILD_DIR}/bin/clang++"
FINAL_CLANGD="${LLVM_BUILD_DIR}/bin/clangd"
FINAL_CLANG_TIDY="${LLVM_BUILD_DIR}/bin/clang-tidy"
FINAL_CLANG_FORMAT="${LLVM_BUILD_DIR}/bin/clang-format"
FINAL_CLANG_INCLUDE_CLEANER="${LLVM_BUILD_DIR}/bin/clang-include-cleaner"
FINAL_LLD="${LLVM_BUILD_DIR}/bin/ld.lld"

MISSING_FINAL_TOOLS=()
[ ! -x "${LLVM_CONFIG}" ] && MISSING_FINAL_TOOLS+=("llvm-config")
[ ! -x "${FINAL_CLANG}" ] && MISSING_FINAL_TOOLS+=("clang")
[ ! -x "${FINAL_CLANGXX}" ] && MISSING_FINAL_TOOLS+=("clang++")
[ ! -x "${FINAL_CLANGD}" ] && MISSING_FINAL_TOOLS+=("clangd")
[ ! -x "${FINAL_CLANG_TIDY}" ] && MISSING_FINAL_TOOLS+=("clang-tidy")
[ ! -x "${FINAL_CLANG_FORMAT}" ] && MISSING_FINAL_TOOLS+=("clang-format")
[ ! -x "${FINAL_CLANG_INCLUDE_CLEANER}" ] && MISSING_FINAL_TOOLS+=("clang-include-cleaner")
[ ! -x "${FINAL_LLD}" ] && MISSING_FINAL_TOOLS+=("ld.lld")

if [ "${#MISSING_FINAL_TOOLS[@]}" -ne 0 ]; then
    echo -e "\e[31mError: LLVM build tree is incomplete under ${LLVM_BUILD_DIR}.\e[39m"
    echo "Missing tools: ${MISSING_FINAL_TOOLS[*]}"
    exit 1
fi

echo -e "\e[32m[COMPLETED] LLVM $(${LLVM_CONFIG} --version) (${BUILD_MODE})\e[39m"
