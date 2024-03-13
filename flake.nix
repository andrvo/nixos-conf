{
  description = "Customized DEV workspaces";

  inputs = {
    wslin.url = "github:nix-community/NixOS-WSL";
    # pkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # localpkgs.url = "nixpkgs";
    localpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    wslpkgs.follows = "wslin/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, wslin, wslpkgs, localpkgs, home-manager }: 
  let 
    user = "mccloud";
    email = "av@gyrus.biz";
    name = "Andr Vo";
  in
  {
    nixosConfigurations = let 
      localConf = { config, pkgs, ... }: 
      {
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
        time.timeZone = "Europe/Kyiv";
        system.stateVersion = config.system.nixos.release;
        programs.zsh.enable = true;
        security.sudo.wheelNeedsPassword = false;
        users.defaultUserShell = pkgs.zsh;
      };
      wslConf = { config, pkgs, ... }:
      {
        wsl.enable = true;
        wsl.defaultUser = "${user}";
        # wsl.docker-desktop.enable = true;
      };
      vmConf = { pkgs, ... }:
      {
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        networking.firewall.enable = false;
        networking.enableIPv6 = false;
        services.openssh.enable = true;
        environment.systemPackages = with pkgs; [
          curl
          git
          vim
        ];
      };
      dockerConf = { config, ... }:
      {
        virtualisation.docker.enable = true;
        users.extraGroups.docker.members = [ "${user}" ];
      };
      userConf = { config, ...}:
      {
        users.users.${user} = { 
          isNormalUser = true; 
          # group = "${user}"; 
          extraGroups = [ "wheel" ]; 
          openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVUner0lOEkh4O9NqWGCkLxhtnEqd7ydNRcwEmiqqAY av@gyrus.biz" ];
        };
        # users.groups.${user} = {};
      };
    in 
    {
      wsl = wslpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          wslin.nixosModules.wsl
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = (import ./home-manager.nix { inherit user name email; });
            };
          }
          localConf
          wslConf
          {
            networking.hostName = "bumblbee";
          }
        ];
      };

      azure = localpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./azure.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = (import ./home-manager.nix { inherit user name email; });
            };
          }
          localConf
          userConf
          vmConf
          dockerConf
          {
            networking.hostName = "nixy";
          }
        ];
      };

      virt = localpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = (import ./home-manager.nix { inherit user name email; });
            };
          }
          localConf
          userConf
          vmConf
          {
            networking.hostName = "nixa";
          }
        ] ++ localpkgs.lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;
      };
    };
  };
}
