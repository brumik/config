FROM ubuntu:24.04

ARG UID=1000
ARG GID=1000
ARG UNAME=levente

# Install system essentials and notification support
RUN apt-get update && apt-get install -y \
    git curl ca-certificates ripgrep jq build-essential libssl-dev zlib1g-dev \
    libnotify-bin xvfb \
        && rm -rf /var/lib/apt/lists/*

# Create levente group with specified GID
RUN groupadd -g ${GID} -o ${UNAME}

# Create levente user with specified UID and primary group
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}

# Create directories that will be mounted as volumes and set ownership
RUN mkdir -p /home/${UNAME}/.config/opencode \
    /home/${UNAME}/.local/share/opencode \
    /home/${UNAME}/.local/share/mise \
    && chown -R ${UNAME}:${UNAME} /home/${UNAME}

USER $UNAME
WORKDIR /home/$UNAME

RUN curl https://mise.jdx.dev/install.sh | sh

RUN curl -fsSL https://opencode.ai/install | bash

ENV PATH="/home/vibeuser/.opencode/bin:/home/${UNAME}/.local/bin:/home/${UNAME}/.local/share/mise/shims:$PATH"

CMD ["tail", "-f", "/dev/null"]
