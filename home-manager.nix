{ config, pkgs, lib, ... }:

let
  user = "mccloud";
  name = "Andr Vo";
  email = "av@gyrus.biz";
  # shared-files = import ../shared/files.nix { inherit config pkgs; };
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = lib.mkForce "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    # file = shared-files // import ./files.nix { inherit user; };
    file = import ./files.nix { inherit user pkgs; };
    stateVersion = "23.11";
  };

  programs = {
	  zsh = {
	    enable = true;
	    autocd = false;

      dotDir = ".config/zsh";
      enableCompletion = true;
      enableAutosuggestions = true;
      shellAliases = {
        l = "ls -alh";
        ll = "ls -l";
        # 0 = "sudo";
        k = "kubectl";
      };

      initExtra = ''
        PROMPT='%# '
        autoload -U promptinit && promptinit
        prompt bart
        umask 022
        alias 0='sudo'
      '';

	    initExtraFirst = ''
        # adding the SSH key
        eval $(/mnt/c/Users/avoit/scoop/apps/ssh-agent-wsl/current/ssh-agent-wsl -r)

	      # if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
	      #   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	      #   . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
	      # fi

	      # Define variables for directories
	      export PATH=$HOME/.local/share/bin:$PATH

	      # Remove history data we don't want to see
	      export HISTIGNORE="pwd:ls:cd"

	      # nix shortcuts
	      shell() {
	          nix-shell '<nixpkgs>' -A "$1"
	      }

	      # Always color ls and group directories
	      # alias ls='ls --color=auto'
	    '';
	  };

	  git = {
	    enable = true;
	    ignores = [ "*.swp" ];
	    userName = name;
	    userEmail = email;
	    lfs = {
	      enable = true;
	    };
	    extraConfig = {
	      init.defaultBranch = "master";
	      core = { 
		    editor = "hx";
	        autocrlf = "input";
	      };
	      pull.rebase = true;
	      # rebase.autoStash = true;
	    };
	  };

	  vim = {
	    enable = true;
	    settings = { ignorecase = true; };
	     };

	  # ssh = {
	  #   enable = true;

	  #   extraConfig = lib.mkMerge [
	  #     ''
	  #       Host github.com
	  #         Hostname github.com
	  #         IdentitiesOnly yes
	  #     ''
	  #     (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
	  #       ''
	  #         IdentityFile /home/${user}/.ssh/id_github
	  #       '')
	  #     (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
	  #       ''
	  #         IdentityFile /Users/${user}/.ssh/id_github
	  #       '')
	  #   ];
	  # };

	  tmux = {
	    enable = true;
	    terminal = "screen-256color";
	  };
	};
}

