FROM golang:latest
ENV DOCKER_CHANNEL=stable \
    DOCKER_VERSION=19.03.2 \
    DOCKER_COMPOSE_VERSION=1.24.1 \
    DOCKER_SQUASH=0.2.0 \
    DEBIAN_FRONTEND=noninteractive \
    TZ="Europe/London" \
    CRANE_VERSION=0.6.0 \
    PACK_VERSION=0.21.1 \
    GH_VERSION=2.4.0
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list
RUN apt-get update && \
    apt-get -y install \
        bash \
        curl \
        iptables \
        util-linux \
        ca-certificates \
        gcc \
        libc-dev \
        libffi-dev \
        libssl-dev \
        make \
        git \
        gh \
        gnupg \
        gpg \
        wget \
        net-tools \
        iproute2 \
        tar \
        vim \
        lsb-release \
        tzdata \
        cgroupfs-mount
RUN go install github.com/paketo-buildpacks/libpak/cmd/create-package@latest
RUN curl \
        --show-error \
        --silent \
        --location \
    "https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz" \
    | tar -C  /usr/local/bin/ -xz crane
RUN (curl -sSL "https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz" | tar -C /usr/local/bin/ --no-same-owner -xzv pack)
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  bionic stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && \
    apt-get install docker-ce docker-ce-cli containerd.io -y