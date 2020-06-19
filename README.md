# golang dev image

> golang development image based on [`golang:latest`](https://hub.docker.com/_/golang/)

## Includes

- `gopher` non-root user with sudo access
  - pass ARG USERNAME to rename
  - ARG USER_UID=1000
  - ARG USER_GID=USER_UID
- ARG LOCALE=en_US.UTF-8
- shell prompt configuration with [starship.rs](https://starship.rs/)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) Powerline font
- go tools required for vs code golang extension
  - gopls
  - delve
  - goimports
  - gorename
  - golangci-lint
- \$GOPATH = /go
- \$GOBIN = /go/bin
