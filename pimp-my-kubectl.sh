#!/bin/bash

# Define variables
KUBECTX_VERSION="v0.9.1"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
VERSION=$(curl - Ls https://dl.k8s.io/release/stable.txt)
ARCH=$(uname -m)

# Install Kubectl
if [ -x "$(command -v kubectl)" ]; then
  echo "kubectl already installed"
else
  case "$OS" in
  linux) curl -LO https://dl.k8s.io/release/$VERSION/bin/linux/$ARCH/kubectl ;;
  darwin) curl -LO https://dl.k8s.io/release/$VERSION/bin/darwin/$ARCH/kubectl ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
  esac
fi

# Install kubectx
if command -v kubectx &>/dev/null; then
  echo "kubectx is already installed"
else
  case "$OSTYPE" in
  linux*)
    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/v0.9.1/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" |
      sudo tar -C /usr/local/bin --strip-components=1 -zxvf - "kubectx"
    ;;
  darwin*)
    brew install kubectx
    ;;
  *)
    echo "Unsupported OS: $OSTYPE"
    exit 1
    ;;
  esac

  echo "kubectx installed successfully"
fi

# Install Krew
(
  set -x
  cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew &
) >/dev/null 2>&1

# Define the list of files to check
readonly RC_FILES="$HOME/.*rc"

# Loop through each file and append aliases and update PATH
for rc_file in $RC_FILES; do
  if grep -q 'alias k=' "$rc_file" && grep -q 'alias kx=' "$rc_file" && grep -q 'PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' "$rc_file"; then
    echo "Aliases and PATH already exist in $rc_file"
  else
    # Append aliases and update PATH
    {
      echo 'alias k=kubectl'
      echo 'alias kx=kubectx'
      echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'
    } >>"$rc_file"

    echo "Updated $rc_file with aliases and PATH"
  fi

  # Reload the file to make changes take effect
  source "$rc_file" >/dev/null 2>&1
done

# Install krew plugins
PLUGINS=(
  "community-images"
  "blame"
  "tree"
  "count"
  "deprecations"
  "datree"
  "colorize-applied"
  "explore"
)

for plugin in "${PLUGINS[@]}"; do
  echo "Installing plugin: $plugin"
  kubectl krew install "$plugin" || true
  echo "Plugin $plugin installed successfully."
done
