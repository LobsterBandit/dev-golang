FROM golang:1.16.0

ARG USERNAME=gopher
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG LOCALE=en_US.UTF-8
ARG WORKDIR=/usr/src

# Configure apt and install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y -q upgrade \
    && apt-get -y -q install --no-install-recommends apt-utils 2>&1 \
    && apt-get -y -q install --no-install-recommends \
    dialog \
    git \
    openssh-client \
    less \
    curl \
    wget \
    unzip \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    locales \
    sudo \
    nano \
    vim \
    fontconfig \
    && echo "$LOCALE UTF-8" >> /etc/locale.gen \
    && locale-gen \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Setup user
RUN adduser --shell /bin/bash --uid $USER_UID --disabled-password --gecos "" $USERNAME \
    && mkdir -p /etc/sudoers.d \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown -R $USERNAME:$USERNAME /go

RUN mkdir -p /home/$USERNAME/.vscode-server/extensions /home/$USERNAME/.vscode-server-insiders/extensions \
    && chown -R $USERNAME /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders

# Powerline font - JetBrains Mono
RUN wget -qO temp.zip $(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep browser_download_url | cut -d '"' -f 4) \
    && unzip temp.zip -d /usr/share/fonts \
    && rm temp.zip \
    && fc-cache -fv \
    && echo "export PATH=\$PATH:\$HOME/.local/bin" | tee -a /root/.bashrc >> /home/$USERNAME/.bashrc

# Setup starship prompt
RUN curl -fsSL https://starship.rs/install.sh | bash -s -- -y \
    && echo "\neval \"\$(starship init bash)\"\n" | tee -a /root/.bashrc >> /home/$USERNAME/.bashrc \
    && chown $USER_UID:$USER_GID /home/$USERNAME/.bashrc \
    && mkdir -p /root/.config /home/$USERNAME/.config \
    && wget -qO- https://raw.githubusercontent.com/LobsterBandit/dotfiles/master/starship.toml \
    | tee -a /root/.config/starship.toml >> /home/$USERNAME/.config/starship.toml \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME/.config

# get go tools
RUN mkdir -p /tmp/go
COPY go.* /tmp/go/
RUN cd /tmp/go \
    && go get github.com/go-delve/delve/cmd/dlv \
    && go get golang.org/x/tools/cmd/goimports \
    && go get golang.org/x/tools/cmd/gorename \
    && go get golang.org/x/tools/gopls \
    && go get github.com/golangci/golangci-lint/cmd/golangci-lint \
    && mv /go/bin/* /usr/local/go/bin \
    #
    # Clean up
    && cd /go \
    && rm -rf /tmp/go \
    && rm -rf /go/src/* /go/pkg

ENV LANG=$LOCALE \
    DEBIAN_FRONTEND=dialog \
    GOBIN=/go/bin \
    USER=$USERNAME

USER $USERNAME

WORKDIR $WORKDIR

ENTRYPOINT [ "bash" ]
