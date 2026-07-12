# Pinned base image (Debian 12 "bookworm", non-root `vscode` user at UID 1000).
# Bump the tag deliberately to control supply-chain input and reproducibility.

FROM mcr.microsoft.com/devcontainers/base:2.1.6-bookworm

ENV HOMEBREW_NONINTERACTIVE=1
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1
USER vscode
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/vscode/.local/bin:/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Copy linux-only Brewfile into the image and install tools. 
# Use a cache mount for Homebrew's download and build cache to speed up subsequent builds.
COPY --chown=vscode:vscode .devcontainer/Brewfile /tmp/Brewfile
RUN --mount=type=cache,target=/home/vscode/.cache/Homebrew,uid=1000,gid=1000 \
    brew bundle --file=/tmp/Brewfile \
    && rm /tmp/Brewfile

USER root
RUN chown -R vscode:vscode /home/linuxbrew \
    && chsh -s /bin/zsh vscode \
    # The base image grants `vscode` passwordless sudo. AI agents (pi, opencode)
    # execute arbitrary shell and must not be able to trivially `sudo` to root,
    # so removing the NOPASSWD entry. sudo remains available but requires a
    # password (none is set by default -> effectively disabled).
    && rm -f /etc/sudoers.d/vscode
USER vscode

CMD ["zsh", "-l"]
