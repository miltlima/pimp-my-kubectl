#!/bin/bash

# Define variables
KUBECTX_VERSION="v0.9.1"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
VERSION=$(curl - Ls https://dl.k8s.io/release/stable.txt)
ARCH=$(uname -m)

# Check os architecture
get_os_arch(){
    case "$ARCH" in
        "x86_64") echo "amd64" ;;
        "arm64") echo "arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}
## Install Kubectl
case "$OS" in
    linux) curl -LO https://dl.k8s.io/release/$VERSION/bin/linux/$ARCH/kubectl ;;
    darwin) curl -LO https://dl.k8s.io/release/$VERSION/bin/darwin/$ARCH/kubectl ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

## Install kubectx 
if [ "$OS" == "linux" ]; then
    curl -LO https://github.com/ahmetb/kubectx/releases/download/v0.9.1/kubectx_$KUBECTX_VERSION_linux_x86_64.tar.gz
    tar -zxvf kubectx_$KUBECTX_VERSION_linux_x86_64.tar.gz
    sudo cp kubectx /usr/local/bin/
    sudo chmod +x /usr/local/bin/kubectx
    export PATH="/usr/local/bin:$PATH"
    rm -rf kubectx kubectx_$KUBECTX_VERSION_linux_x86_64.tar.gz
elif [ "$os" == "darwin" ]; then
    brew install kubectx
else
    echo "Unsupported OS: $OS"
fi

## Install Krew 
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

shell=$(basename "$SHELL")
rc_file="$HOME/.${shell}rc"

# Append aliases to the correct rc file
echo "alias k=kubectl" >> "$rc_file"
echo "alias kx=kubectx" >> "$rc_file"
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$rc_file"

# Source the file to make the changes take effect
source "$rc_file"

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
    kubectl krew install "$plugin"
done