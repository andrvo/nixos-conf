{
  description = "Customized DEV workspaces";

  inputs = {
    wslin.url = "github:nix-community/NixOS-WSL";
    # pkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # localpkgs.url = "nixpkgs";
    localpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wslpkgs.follows = "wslin/nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "localpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "wslin/nixpkgs"; # this comes to bumblbee only for now
    agenix.inputs.darwin.follows = "";
  };
  outputs = { self, wslin, wslpkgs, localpkgs, unstablepkgs, home-manager, agenix }@inputs: 
  let 
    inherit (self) outputs;
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
        specialArgs = { inherit inputs outputs; };
        modules = [
          wslin.nixosModules.wsl
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = (import ./home-manager.nix { inherit user name email; });
              extraSpecialArgs = { inherit inputs outputs; };
            };
          }
          localConf
          wslConf
          {
            networking.hostName = "bumblbee";
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }
        ];
      };

      azure = localpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./azure.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = (import ./home-manager.nix { inherit user name email; });
              extraSpecialArgs = { inherit inputs outputs; };
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
        specialArgs = { inherit inputs outputs; };
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = (import ./home-manager.nix { inherit user name email; });
              extraSpecialArgs = { inherit inputs outputs; };
            };
          }
          localConf
          userConf
          vmConf
          {
            networking.hostName = "nixa";
            environment.systemPackages = [ agenix.packages.aarch64-linux.default ];
            hardware.parallels.enable = true;
          }
        ] ++ localpkgs.lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;
      };
    };
  };
}
