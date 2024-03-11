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
      localConf = { config, ... }: 
      {
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
        time.timeZone = "Europe/Kyiv";
        system.stateVersion = config.system.nixos.release;
        programs.zsh.enable = true;
        security.sudo.wheelNeedsPassword = false;
      };
      wslConf = { config, pkgs, ... }:
      {
        users.defaultUserShell = pkgs.zsh;
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
          }
        ] ++ localpkgs.lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;
      };
    };
  };
}
