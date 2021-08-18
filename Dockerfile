FROM debian:10

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    curl \
    gcc \
    g++ \
    perl \
    python3.7 \
    python3-distutils \
    python3-venv \
    python \
    python-dev \
    python-setuptools \
    libgmp10 \
    libgmp-dev \
    locales \
    bash \
    make \
    mawk \
    file \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/* && \
    \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 20 && \
    update-alternatives --set python /usr/bin/python3.7

ENV CHPL_VERSION 1.24.1
ENV CHPL_ROOT    /opt/chapel
ENV CHPL_HOME    ${CHPL_ROOT}/${CHPL_VERSION}
ENV CHPL_GMP     system

RUN mkdir -p "${CHPL_ROOT}" \
    && wget -q -O - "https://github.com/chapel-lang/chapel/releases/download/${CHPL_VERSION}/chapel-${CHPL_VERSION}.tar.gz" | tar -xzC "${CHPL_ROOT}" --transform 's/chapel-//' \
    && make -C "${CHPL_HOME}" \
    && make -C "${CHPL_HOME}" chpldoc test-venv mason \
    && make -C "${CHPL_HOME}" cleanall \
    && mv "${CHPL_HOME}/bin/linux64-$(uname -m)" "${CHPL_HOME}/bin/linux64" && \
    \
# Configure locale
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV PATH="$PATH:${CHPL_HOME}/bin/linux64:${CHPL_HOME}/util"