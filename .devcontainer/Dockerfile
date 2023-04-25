# syntax=docker/dockerfile:1.5-labs

# bionic[18.04], focal[20.04], jammy[22.04], kinetic[22.10], lunar[23.04]
ARG VARIANT="jammy"

FROM ubuntu:${VARIANT}

ARG DEBIAN_FRONTEND="noninteractive"

# Some mirrors may require handshake

RUN <<EOF
    apt-get update
    apt-get -y install --no-install-recommends ca-certificates

    base_url="http://archive.ubuntu.com/ubuntu"
    mirror_url="mirror://mirrors.ubuntu.com/mirrors.txt"
    sed -e "s%${base_url}%${mirror_url}%" -i "/etc/apt/sources.list"

    apt-get update
    apt-get -y install --no-install-recommends gnupg2 wget
    apt-get -y clean
    apt-get -y autoclean
    apt-get -y autoremove
    rm -rf /var/lib/apt/lists/*
EOF

# Add custom PPA's

RUN <<EOF
    add_apt_repository() {
        filename="${1}"
        toolchain="${2}"
        asc_url="${3}"

        asc_path="/tmp/${filename}.asc"
        gpg_path="/usr/share/keyrings/${filename}.gpg"

        wget -O "${asc_path}" "${asc_url}"
        gpg --batch --dearmor --no-tty --output "${gpg_path}" "${asc_path}"
        chmod 644       "${gpg_path}"
        chown root:root "${gpg_path}"
        rm -rf "${asc_path}"

        {
            echo "deb     [signed-by=${gpg_path}] ${toolchain}"
            echo "deb-src [signed-by=${gpg_path}] ${toolchain}"
            echo
        } >> "/etc/apt/sources.list.d/${filename}.list"
    }

    . /etc/os-release

    add_apt_repository "deadsnakes"         "https://ppa.launchpadcontent.net/deadsnakes/nightly/ubuntu      ${VERSION_CODENAME}    main" "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf23c5a6cf475977595c89f51ba6932366a755776"
    add_apt_repository "deadsnakes"         "https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu          ${VERSION_CODENAME}    main" "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf23c5a6cf475977595c89f51ba6932366a755776"
    add_apt_repository "kitware"            "https://apt.kitware.com/ubuntu                                  ${VERSION_CODENAME}    main" "https://apt.kitware.com/keys/kitware-archive-latest.asc"
    add_apt_repository "kitware"            "https://apt.kitware.com/ubuntu                                  ${VERSION_CODENAME}-rc main" "https://apt.kitware.com/keys/kitware-archive-latest.asc"
    add_apt_repository "ubuntu-toolchain-r" "https://ppa.launchpadcontent.net/ubuntu-toolchain-r/ppa/ubuntu  ${VERSION_CODENAME}    main" "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x60c317803a41ba51845e371a1e9377a2ba9ef27f"
    add_apt_repository "ubuntu-toolchain-r" "https://ppa.launchpadcontent.net/ubuntu-toolchain-r/test/ubuntu ${VERSION_CODENAME}    main" "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x60c317803a41ba51845e371a1e9377a2ba9ef27f"
EOF

# Setup locales and timezone

ENV TZ="UTC"

RUN <<EOF
    apt-get update
    apt-get -y install --no-install-recommends locales tzdata
    apt-get -y clean
    apt-get -y autoclean
    apt-get -y autoremove
    rm -rf /var/lib/apt/lists/*

    sed -i "/etc/locale.gen" -e "/en_US.UTF-8/s/^# //g"
    locale-gen

    ln -fs "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
    dpkg-reconfigure tzdata
EOF

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

# Install GCC

ARG GCC_VER="12"

RUN <<EOF
    apt-get update
    apt-get -y install --no-install-recommends g++-${GCC_VER} gcc-${GCC_VER} gdb make ninja-build
    apt-get -y clean
    apt-get -y autoclean
    apt-get -y autoremove
    rm -rf /var/lib/apt/lists/*

    update-alternatives --install "/usr/local/bin/gcc" gcc "/usr/bin/gcc-${GCC_VER}" 1
    update-alternatives --install "/usr/local/bin/g++" g++ "/usr/bin/g++-${GCC_VER}" 1
EOF

# Install Python

ARG PYTHON_VER="3.11"
ARG PIP_URL="https://bootstrap.pypa.io/get-pip.py"

ENV PYTHONUNBUFFERED="1"

RUN <<EOF
    apt-get update
    apt-get -y install --no-install-recommends python${PYTHON_VER} python${PYTHON_VER}-dev python${PYTHON_VER}-venv
    apt-get -y clean
    apt-get -y autoclean
    apt-get -y autoremove
    rm -rf /var/lib/apt/lists/*

    update-alternatives --install "/usr/local/bin/python3" python3 "/usr/bin/python${PYTHON_VER}" 1

    wget -O - ${PIP_URL} | python3
    python3 -m pip install --upgrade pip setuptools wheel
EOF

# Install common

RUN <<EOF
    apt-get update
    apt-get -y install --no-install-recommends lsb-release software-properties-common
    apt-get -y install --no-install-recommends git git-lfs neovim
    apt-get -y clean
    apt-get -y autoclean
    apt-get -y autoremove
    rm -rf /var/lib/apt/lists/*
EOF

# Install LLVM

ARG LLVM_URL="https://apt.llvm.org/llvm.sh"
ARG LLVM_VER="16"

RUN <<EOF
    wget -O - ${LLVM_URL} | bash -s ${LLVM_VER} all
    echo "update-alternatives --install /usr/local/bin/clang       clang       /usr/bin/clang-${LLVM_VER}       1 $(find -L "/usr/lib/llvm-${LLVM_VER}/bin" -type f -executable -not -name "clang"       -not -name "llvm*" -printf "--slave /usr/local/bin/%f %f /usr/bin/%f-${LLVM_VER} ")" | sh
    echo "update-alternatives --install /usr/local/bin/llvm-config llvm-config /usr/bin/llvm-config-${LLVM_VER} 1 $(find -L "/usr/lib/llvm-${LLVM_VER}/bin" -type f -executable -not -name "llvm-config"      -name "llvm*" -printf "--slave /usr/local/bin/%f %f /usr/bin/%f-${LLVM_VER} ")" | sh
EOF

# Install optional

# Some packages request that Conan use the system package manager to install
# a few dependencies. This flag allows Conan to proceed with these installations;
# leaving this flag undefined can cause some installation failures.
ENV CONAN_SYSREQUIRES_MODE="enabled"
# By default, anything you run in Docker is done as superuser.
# Conan runs some install commands as superuser, and will prepend `sudo` to
# these commands, unless `CONAN_SYSREQUIRES_SUDO=0` is in your env variables.
ENV CONAN_SYSREQUIRES_SUDO="0"

RUN <<EOF
    apt-get update
    apt-get -y install --no-install-recommends cmake cmake-curses-gui
    apt-get -y install --no-install-recommends ccache cppcheck doxygen graphviz
    apt-get -y clean
    apt-get -y autoclean
    apt-get -y autoremove
    rm -rf /var/lib/apt/lists/*

    python3 -m pip install --upgrade cmakelang conan cpplint
EOF

ARG IWYU_SRC="/tmp/include-what-you-use"
ARG IWYU_BUILD="${IWYU_SRC}/build"
ARG IWYU_URL="https://github.com/include-what-you-use/include-what-you-use"

RUN <<EOF
    git clone --branch="clang_${LLVM_VER}" "${IWYU_URL}" "${IWYU_SRC}"

    CC="clang-${LLVM_VER}" CXX="clang++-${LLVM_VER}"
    mkdir -p "${IWYU_BUILD}"

    cmake -B "${IWYU_BUILD}" -S "${IWYU_SRC}" -DCMAKE_PREFIX_PATH="/usr/lib/llvm-${LLVM_VER}" -G "Ninja"
    cmake --build   "${IWYU_BUILD}" -j$(nproc)
    cmake --install "${IWYU_BUILD}"

    rm -rf "${IWYU_SRC}"

    iwyu_resources="$(include-what-you-use --print-resource-dir 2>/dev/null)"
    llvm_resources="$(clang-${LLVM_VER}    --print-resource-dir 2>/dev/null)"

    mkdir -p "${iwyu_resources}"
    ln -s    "${llvm_resources}/include" "${iwyu_resources}/include"
EOF

# Allow the user to set compiler defaults
ARG USE_CLANG
# if --build-arg USE_CLANG=1, set CC to 'clang' or set to null otherwise.
ENV CC="${USE_CLANG:+"clang"}"
ENV CXX="${USE_CLANG:+"clang++"}"
# if CC is null, set it to 'gcc' (or leave as is otherwise).
ENV CC="${CC:-"gcc"}"
ENV CXX="${CXX:-"g++"}"

CMD sleep infinity
