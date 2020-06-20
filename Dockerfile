FROM golang:latest

ARG USERNAME=gopher
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG LOCALE=en_US.UTF-8

# Configure apt and install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get upgrade \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    && apt-get -y install --no-install-recommends \
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

# get go tools
RUN go get github.com/go-delve/delve/cmd/dlv \
    && go get golang.org/x/tools/cmd/goimports \
    && go get golang.org/x/tools/cmd/gorename \
    && GO111MODULE=on go get golang.org/x/tools/gopls@latest \
    && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /go/bin v1.27.0 \
    && mv /go/bin/* /usr/local/go/bin \
    #
    # Clean up
    && rm -rf /go/src/* /go/pkg

# Setup user
RUN adduser --shell /bin/bash --uid $USER_UID --disabled-password --gecos "" $USERNAME \
    && mkdir -p /etc/sudoers.d \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown -R $USERNAME:$USERNAME /go

RUN mkdir -p /home/$USERNAME/.vscode-server/extensions /home/$USERNAME/.vscode-server-insiders/extensions \
    && chown -R $USERNAME /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders

# Powerline font - JetBrains Mono
RUN wget -qO temp.zip https://github.com/JetBrains/JetBrainsMono/releases/download/v1.0.6/JetBrainsMono-1.0.6.zip \
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

ENV LANG=$LOCALE \
    DEBIAN_FRONTEND=dialog \
    GOBIN=/go/bin \
    USER=$USERNAME

USER $USERNAME

WORKDIR /go

CMD [ "bash" ]
