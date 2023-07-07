# syntax=docker/dockerfile:1.5-labs

# [18.04]: bionic, [20.04]: focal, [22.04]: jammy, [22.10]: kinetic, [23.04]: lunar, [23.10]: mantic
ARG VARIANT="jammy"

FROM ubuntu:${VARIANT}

ARG DEBIAN_FRONTEND="noninteractive"

# ------------------------------------------------------------------------------

RUN <<EOF
    rm -rf "/etc/apt/apt.conf.d/docker-clean"
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >> "/etc/apt/apt.conf.d/keep-cache"
EOF

# ------------------------------------------------------------------------------

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    apt-get update
    apt-get -y install --no-install-recommends ca-certificates

    mirror_url="mirror://mirrors.ubuntu.com/mirrors.txt"
    ubuntu_url="http://archive.ubuntu.com/ubuntu"
    sed -e "s%${ubuntu_url}%${mirror_url}%" -i "/etc/apt/sources.list"

    apt-get update
    apt-get -y install --no-install-recommends gnupg2 wget
EOF

# ------------------------------------------------------------------------------

ENV TZ="UTC"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    apt-get update
    apt-get -y install --no-install-recommends locales tzdata

    sed -e "/en_US.UTF-8/s/^# //g" -i "/etc/locale.gen"
    locale-gen

    ln -fs "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
    dpkg-reconfigure tzdata
EOF

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

# ------------------------------------------------------------------------------

ARG GCC_VERSION="12"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    . /etc/os-release

    {
        filename="ubuntu-toolchain-r-ubuntu-ppa-${VERSION_CODENAME}"
        key="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x60c317803a41ba51845e371a1e9377a2ba9ef27f"
        url="https://ppa.launchpadcontent.net/ubuntu-toolchain-r/ppa/ubuntu"
        if wget --spider "${url}/dists/${VERSION_CODENAME}"; then
            wget -O - "${key}" | gpg --batch --dearmor --no-tty --output "/usr/share/keyrings/${filename}.gpg"
            echo "deb [signed-by=/usr/share/keyrings/${filename}.gpg] ${url} ${VERSION_CODENAME} main" >> "/etc/apt/sources.list.d/${filename}.list"
        fi
    }

    {
        filename="ubuntu-toolchain-r-ubuntu-test-${VERSION_CODENAME}"
        key="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x60c317803a41ba51845e371a1e9377a2ba9ef27f"
        url="https://ppa.launchpadcontent.net/ubuntu-toolchain-r/test/ubuntu"
        if wget --spider "${url}/dists/${VERSION_CODENAME}"; then
            wget -O - "${key}" | gpg --batch --dearmor --no-tty --output "/usr/share/keyrings/${filename}.gpg"
            echo "deb [signed-by=/usr/share/keyrings/${filename}.gpg] ${url} ${VERSION_CODENAME} main" >> "/etc/apt/sources.list.d/${filename}.list"
        fi
    }

    apt-get update
    apt-get -y install --no-install-recommends g++-${GCC_VERSION} gcc-${GCC_VERSION} gdb make
    update-alternatives --install "/usr/local/bin/gcc" gcc "/usr/bin/gcc-${GCC_VERSION}" 1
    update-alternatives --install "/usr/local/bin/g++" g++ "/usr/bin/g++-${GCC_VERSION}" 1
EOF

# ------------------------------------------------------------------------------

ARG LLVM_VERSION="16"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    apt-get update
    apt-get -y install --no-install-recommends gnupg lsb-release software-properties-common wget

    wget -O - "https://apt.llvm.org/llvm.sh" | bash -s ${LLVM_VERSION} all
    echo "update-alternatives --install /usr/local/bin/clang       clang       /usr/bin/clang-${LLVM_VERSION}       1 $(find -L "/usr/lib/llvm-${LLVM_VERSION}/bin" -type f -executable -not -name "clang"       -not -name "llvm*" -printf "--slave /usr/local/bin/%f %f /usr/bin/%f-${LLVM_VERSION} ")" | sh
    echo "update-alternatives --install /usr/local/bin/llvm-config llvm-config /usr/bin/llvm-config-${LLVM_VERSION} 1 $(find -L "/usr/lib/llvm-${LLVM_VERSION}/bin" -type f -executable -not -name "llvm-config"      -name "llvm*" -printf "--slave /usr/local/bin/%f %f /usr/bin/%f-${LLVM_VERSION} ")" | sh
EOF

# ------------------------------------------------------------------------------

ARG PYTHON_VERSION="3.11"

ENV PYTHONUNBUFFERED="1"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    . /etc/os-release

    {
        filename="deadsnakes-ubuntu-nightly-${VERSION_CODENAME}"
        key="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf23c5a6cf475977595c89f51ba6932366a755776"
        url="https://ppa.launchpadcontent.net/deadsnakes/nightly/ubuntu"
        if wget --spider "${url}/dists/${VERSION_CODENAME}"; then
            wget -O - "${key}" | gpg --batch --dearmor --no-tty --output "/usr/share/keyrings/${filename}.gpg"
            echo "deb [signed-by=/usr/share/keyrings/${filename}.gpg] ${url} ${VERSION_CODENAME} main" >> "/etc/apt/sources.list.d/${filename}.list"
        fi
    }

    {
        filename="deadsnakes-ubuntu-ppa-${VERSION_CODENAME}"
        key="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf23c5a6cf475977595c89f51ba6932366a755776"
        url="https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu"
        if wget --spider "${url}/dists/${VERSION_CODENAME}"; then
            wget -O - "${key}" | gpg --batch --dearmor --no-tty --output "/usr/share/keyrings/${filename}.gpg"
            echo "deb [signed-by=/usr/share/keyrings/${filename}.gpg] ${url} ${VERSION_CODENAME} main" >> "/etc/apt/sources.list.d/${filename}.list"
        fi
    }

    apt-get update
    apt-get -y install --no-install-recommends python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv
    update-alternatives --install "/usr/local/bin/python3" python3 "/usr/bin/python${PYTHON_VERSION}" 1

    wget -O - "https://bootstrap.pypa.io/get-pip.py" | python3 - --break-system-packages
    python3 -m pip install --upgrade pip setuptools wheel        --break-system-packages
EOF

# ------------------------------------------------------------------------------

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    {
        wget -O - "https://apt.kitware.com/kitware-archive.sh" | sh -s -- --rc
    } || true

    apt-get update
    apt-get -y install --no-install-recommends cmake cmake-curses-gui ninja-build
    apt-get -y install --no-install-recommends ccache cppcheck doxygen graphviz

    python3 -m pip install --upgrade cmakelang cpplint --break-system-packages
EOF

# ------------------------------------------------------------------------------

RUN <<EOF
    {
        mkdir -p "/usr/src/iwyu"
        wget -O - "https://github.com/include-what-you-use/include-what-you-use/archive/refs/heads/clang_${LLVM_VERSION}.tar.gz" ||
        wget -O - "https://github.com/include-what-you-use/include-what-you-use/archive/refs/heads/master.tar.gz"
    } | tar --directory "/usr/src/iwyu" --extract --gzip --strip-components 1

    CC="clang-${LLVM_VERSION}"
    CXX="clang++-${LLVM_VERSION}"

    mkdir -p        "/usr/src/iwyu/build"
    cmake -B        "/usr/src/iwyu/build" -S "/usr/src/iwyu" -DCMAKE_PREFIX_PATH="/usr/lib/llvm-${LLVM_VERSION}" -G "Ninja"
    cmake --build   "/usr/src/iwyu/build" -j $(nproc --all)
    cmake --install "/usr/src/iwyu/build"
    rm -rf "/usr/src/iwyu"

    iwyu_resources="$(include-what-you-use  --print-resource-dir 2>/dev/null)"
    llvm_resources="$(clang-${LLVM_VERSION} --print-resource-dir 2>/dev/null)"

    mkdir -p "${iwyu_resources}"
    ln -s    "${llvm_resources}/include" "${iwyu_resources}/include"
EOF

# ------------------------------------------------------------------------------

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    apt-get update
    apt-get -y install --no-install-recommends git git-lfs neovim
EOF

# ------------------------------------------------------------------------------

CMD sleep infinity
