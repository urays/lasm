#!/bin/bash
# By urays@foxmail.com. Note: only for Ubuntu 22.04
set -eu

if [ "${EUID}" -ne 0 ]; then
    echo "Error: this script must be run as root."
    echo "Please run: sudo bash scripts/install-core-dev.sh"
    exit 1
fi

LLVM_APT_MAJOR=21
LLVM_LEGACY_KEY_FPR="6084F3CF814B57C1CF12EFD515CF4D18AF4F7421"

# Update apt sources
# echo -e "deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse\n\
#     deb-src http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse\n\
#     deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse\n\
#     deb-src http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse\n\
#     deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse\n\
#     deb-src http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse\n\
#     deb http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse\n\
#     deb-src http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse\n\
#     deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse\n\
#     deb-src http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse"> /etc/apt/sources.list.d/aliyun.list

apt-get update && apt-get install -y \
    sudo \
    apt-transport-https \
    wget \
    ca-certificates \
    gnupg \
    lsb-release

LLVM_APT_SUITE="$(lsb_release -sc)"
LLVM_APT_KEYRING="/usr/share/keyrings/llvm-archive-keyring.gpg"
LLVM_APT_LIST="/etc/apt/sources.list.d/llvm-apt.list"
LLVM_BIN_DIR="/usr/bin"
LLVM_APT_KEY_TMP="$(mktemp /tmp/llvm-snapshot.gpg.key.XXXXXX)"
trap 'rm -f "${LLVM_APT_KEY_TMP}"' EXIT

wget -qO "${LLVM_APT_KEY_TMP}" https://apt.llvm.org/llvm-snapshot.gpg.key
gpg --dearmor --yes -o "${LLVM_APT_KEYRING}" "${LLVM_APT_KEY_TMP}"
if gpg --batch --no-default-keyring --keyring /etc/apt/trusted.gpg \
    --list-keys "${LLVM_LEGACY_KEY_FPR}" >/dev/null 2>&1; then
    gpg --batch --yes --no-default-keyring --keyring /etc/apt/trusted.gpg \
        --delete-key "${LLVM_LEGACY_KEY_FPR}"
fi
echo "deb [signed-by=${LLVM_APT_KEYRING}] https://apt.llvm.org/${LLVM_APT_SUITE}/ llvm-toolchain-${LLVM_APT_SUITE}-${LLVM_APT_MAJOR} main" > "${LLVM_APT_LIST}"
apt-get update

# Install libraries for building c++ core on Ubuntu.
apt update && apt install -y \
    build-essential \
    curl \
    g++ \
    gdb \
    git \
    graphviz \
    libcurl4-openssl-dev \
    libopenblas-dev \
    libssl-dev \
    libtinfo-dev \
    libz-dev \
    lsb-core \
    texinfo \
    make \
    cmake \
    flex \
    bison \
    vim   \
    ninja-build \
    ccache \
    parallel \
    pkg-config \
    unzip \
    doxygen \
    gcovr \
    valgrind \
    z3 libz3-dev \
    clang-${LLVM_APT_MAJOR} \
    lld-${LLVM_APT_MAJOR} \
    qtwayland5 \
    libgmp-dev \
    libopenblas-dev \
    poppler-utils \
    qpdf \
    universal-ctags \
    ripgrep

ln -sf "${LLVM_BIN_DIR}/clang-${LLVM_APT_MAJOR}" "${LLVM_BIN_DIR}/clang"
ln -sf "${LLVM_BIN_DIR}/clang++-${LLVM_APT_MAJOR}" "${LLVM_BIN_DIR}/clang++"
ln -sf "${LLVM_BIN_DIR}/lld-${LLVM_APT_MAJOR}" "${LLVM_BIN_DIR}/lld"
ln -sf "${LLVM_BIN_DIR}/ld.lld-${LLVM_APT_MAJOR}" "${LLVM_BIN_DIR}/ld.lld"
    
# Update global linker.
# rm -rf /usr/bin/ld
# sudo ln -s  $(which ld.lld) /usr/bin/ld

apt update && apt upgrade -y
apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
