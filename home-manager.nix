{user, name, email}: { inputs, outputs, config, pkgs, lib, ... }:

{

  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = lib.mkForce "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    # file = shared-files // import ./files.nix { inherit user; };
    file = import ./files.nix { inherit user pkgs; };
    stateVersion = "23.11";
  };

  programs = {
    helix = {
      enable = true;
      package = inputs.unstablepkgs.legacyPackages.${pkgs.system}.helix;
      settings = {
        theme = "kanagawa";
        editor = {
    			true-color = true;
    			line-number = "relative";
    			lsp.display-inlay-hints = true;
    			soft-wrap.enable = true;
        };
      };
    };

	  zsh = {
	    enable = true;
	    autocd = false;

      dotDir = ".config/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
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
        export EDITOR=hx
        
        # adding the SSH key
        if [ -e /mnt/c/Users/avoit/scoop/apps/ssh-agent-wsl/current/ssh-agent-wsl ]; then
          eval $(/mnt/c/Users/avoit/scoop/apps/ssh-agent-wsl/current/ssh-agent-wsl -r)
        fi

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

    mercurial = {
      enable = true;
      userName = name;
      userEmail = email;
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
      aliases = {
        ci = "commit";
        st = "status";
        sta = "status";
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

