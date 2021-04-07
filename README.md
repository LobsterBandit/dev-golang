# golang dev image

> golang development image based on [`golang`](https://hub.docker.com/_/golang/) official images

## Includes

- `gopher` non-root user with sudo access
- Build args and defaults:
  - ARG USERNAME=gopher
  - ARG USER_UID=1000
  - ARG USER_GID=USER_UID
  - ARG WORKDIR=/usr/src
  - ARG LOCALE=en_US.UTF-8
- shell prompt configuration with [starship.rs](https://starship.rs/)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) Powerline font
- [go tools required for vs code golang extension](https://github.com/golang/vscode-go/blob/master/docs/tools.md)
  - [gopls](https://github.com/golang/tools/tree/master/gopls)
  - [delve](github.com/go-delve/delve)
  - [gopkgs](https://github.com/uudashr/gopkgs)
  - [go-outline](github.com/ramya-rao-a/go-outline)
  - [golangci-lint](https://golangci-lint.run/)
- \$GOPATH = /go
- \$GOBIN = /go/bin
