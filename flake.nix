{
  description = "Customized WSL";

  inputs = {
    wslin.url = "github:nix-community/NixOS-WSL";
    # pkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    localpkgs.url = "nixpkgs";
    wslpkgs.follows = "wslin/nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, wslin, wslpkgs, localpkgs, home-manager }: 
  let 
    user = "mccloud";
  in
  {

    nixosModules.default = wslin.nixosModules.wsl;
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
        networking.hostName = "bumblbee";
        wsl.enable = true;
        wsl.defaultUser = "${user}";
        # wsl.docker-desktop.enable = true;
      };
    in 
    {
      wsl = wslpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./home-manager.nix;
            };
          }
          self.nixosModules.default
          localConf
          wslConf
        ];
      };
      virt = localpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          /etc/nixos/hardware-configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./home-manager.nix;
            };
          }
          self.nixosModules.default
          localConf
          {
            networking.hostName = "nixa";
            users.users.${user} = { 
              isNormalUser = true; 
              # group = "${user}"; 
              extraGroups = [ "wheel" ]; 
              openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVUner0lOEkh4O9NqWGCkLxhtnEqd7ydNRcwEmiqqAY av@gyrus.biz" ];
            };
            # users.groups.${user} = {};
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            networking.firewall.enable = false;
            networking.enableIPv6 = false;
            services.openssh.enable = true;
            security.sudo.wheelNeedsPassword = false;
            
          }
        ]; # ++ localpkgs.lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;
      };
    };
  };
}
