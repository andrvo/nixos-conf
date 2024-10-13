{ pkgs }:

with pkgs; [
  # gnumake
  # cmake
  home-manager

  bc # old school calculator
  # Testing and development tools
  direnv

  tree
  unixtools.ifconfig
  unixtools.netstat
  dig

  # General packages for development and system management
  btop
  coreutils
  killall
  # openssh
  wget
  zip

  # Cloud-related tools and SDKs
  # docker
  # docker-compose

  # Text and terminal utilities
  htop
  hunspell
  iftop
  jq
  ripgrep
  tree
  tmux
  unzip

  git
  mercurial

  azure-cli
  kubectl

  yazi

]

