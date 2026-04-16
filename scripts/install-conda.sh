#!/bin/bash
# By urays@foxmail.com
# Note: run this script before exec /opt/conda/bin/conda init
set -eu

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Use sudo.

# Install Conda
if [ ! -d "/opt/conda" ]; then
    cd /tmp && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda
    /opt/conda/bin/conda upgrade -y --all
    /opt/conda/bin/conda clean -ya
    /opt/conda/bin/conda install conda-build conda-verify -y
    chmod -R a+w /opt/conda/
    rm -rf /tmp/Miniconda3-latest-Linux-x86_64.sh
fi

# Do not use sudo.

# Check if nvcc exists in PATH
# https://developer.nvidia.com/cuda-12-8-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local
# export PATH=/usr/local/cuda/bin:$PATH
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
# https://developer.nvidia.com/cudnn-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local
if command -v nvcc &> /dev/null; then
    echo "nvcc is found. Version:"
    nvcc -V
else
    echo "[ERROR] nvcc is not installed or not in PATH."
    echo "Check CUDA toolkit installation and ensure it is added to PATH."
    exit 1
fi

echo -e "channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
  - https://repo.anaconda.com/pkgs/main
  - https://repo.anaconda.com/pkgs/r
show_channel_urls: true
auto_activate_base: false" > ~/.condarc

if ! { conda env list | grep 'tens'; } >/dev/null 2>&1; then
   conda create -n tens python=3.12
fi

# Check if 'tens' conda environment is activated
if [[ -z "${CONDA_DEFAULT_ENV:-}" || "${CONDA_DEFAULT_ENV:-}" != "tens" ]]; then
    echo "Error: 'tens' conda environment is not activated."
    echo "Please run: conda activate tens"
    exit 1
fi

conda install -y libstdcxx-ng -c conda-forge # [Fix] libstdc++.so.6: version 'GLIBCXX_3.4.30' not found.

##2.7.1
# pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip3 install -r ${SCRIPT_DIR}/requirements.txt
# conda clean --all
